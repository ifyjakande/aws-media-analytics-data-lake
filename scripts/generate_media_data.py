import boto3
import json
import random
import uuid
from datetime import datetime, timedelta
import time

# Initialize S3 client
s3_client = boto3.client('s3')
BUCKET_NAME = 'media-datalake-iceberg-demo'

# Reference data for synthetic generation
content_types = ['movie', 'series', 'documentary', 'music_video', 'short_film']
genres = ['action', 'comedy', 'drama', 'science_fiction', 'horror', 'thriller', 'romance', 'animation']
ratings = ['G', 'PG', 'PG-13', 'R', 'NC-17', 'TV-Y', 'TV-G', 'TV-PG', 'TV-14', 'TV-MA']
platforms = ['web', 'mobile_ios', 'mobile_android', 'smart_tv', 'gaming_console']
countries = ['US', 'UK', 'CA', 'AU', 'FR', 'DE', 'JP', 'BR', 'IN', 'MX']

# Generate content metadata (movies, series, documentaries)
def generate_content_metadata(num_records=100):
    records = []
    for i in range(1, num_records + 1):
        content_id = f"CONT{i:06d}"
        is_series = random.choice(content_types) == 'series'
        
        record = {
            'content_id': content_id,
            'title': f"Sample Media Title {i}",
            'content_type': random.choice(content_types),
            'genre': random.choice(genres),
            'release_date': (datetime.now() - timedelta(days=random.randint(1, 1000))).strftime('%Y-%m-%d'),
            'rating': random.choice(ratings),
            'duration_minutes': random.randint(1, 180),
            'is_original': random.choice([True, False]),
            'language': random.choice(['en', 'es', 'fr', 'de', 'ja', 'ko', 'hi']),
            'creator': f"Creator Studio {random.randint(1, 20)}",
            'description': f"This is a sample description for content {content_id}.",
            'tags': random.sample(['trending', 'popular', 'exclusive', 'award_winning', 'new_release'], random.randint(1, 3))
        }
        
        # Add series-specific fields if content is a series
        if is_series:
            record['season_count'] = random.randint(1, 5)
            record['episode_count'] = random.randint(8, 24) * record['season_count']
        
        records.append(record)
    
    return records

# Generate viewing data (user viewing sessions)
def generate_viewing_data(content_metadata, num_records=1000):
    records = []
    
    for i in range(num_records):
        # Pick a random piece of content
        content = random.choice(content_metadata)
        start_time = datetime.now() - timedelta(days=random.randint(0, 30), hours=random.randint(0, 23), minutes=random.randint(0, 59))
        
        # Calculate realistic view duration and completion percentage
        view_duration = random.randint(1, int(content.get('duration_minutes', 90)))
        
        # Handle series episodes differently
        if content.get('content_type') == 'series':
            # For series, add season and episode numbers
            season = random.randint(1, content.get('season_count', 1))
            episode = random.randint(1, content.get('episode_count', 10) // content.get('season_count', 1))
            content_specific_id = f"{content['content_id']}_S{season:02d}E{episode:02d}"
        else:
            content_specific_id = content['content_id']
        
        record = {
            'view_id': str(uuid.uuid4()),
            'user_id': f"USER{random.randint(1, 10000):07d}",
            'content_id': content_specific_id,
            'view_date': start_time.strftime('%Y-%m-%d'),
            'start_time': start_time.strftime('%Y-%m-%d %H:%M:%S'),
            'view_duration_minutes': view_duration,
            'completion_percentage': min(100, int((view_duration / content.get('duration_minutes', 90)) * 100)),
            'platform': random.choice(platforms),
            'device_type': random.choice(['TV', 'Phone', 'Tablet', 'Computer', 'Console']),
            'location': random.choice(countries),
            'streaming_quality': random.choice(['SD', 'HD', 'FHD', '4K']),
            'is_downloaded': random.choice([True, False])
        }
        
        records.append(record)
    
    return records

# Generate engagement data (likes, ratings, shares)
def generate_engagement_data(viewing_data, num_records=500):
    records = []
    
    for _ in range(num_records):
        # Pick a random viewing record
        view = random.choice(viewing_data)
        
        # Not all views have engagement - add some realism
        if random.random() < 0.7:  # 70% chance of engagement
            record = {
                'engagement_id': str(uuid.uuid4()),
                'view_id': view['view_id'],
                'user_id': view['user_id'],
                'content_id': view['content_id'],
                'engagement_date': view['view_date'],
                'rating': random.randint(1, 5) if random.random() < 0.3 else None,
                'liked': random.choice([True, False, None]),
                'added_to_list': random.choice([True, False, None]),
                'shared': random.choice([True, False, None]),
                'comment_added': random.choice([True, False, None]),
                'engagement_type': random.choice(['like', 'rate', 'share', 'comment', 'add_to_list'])
            }
            
            records.append(record)
    
    return records

def main():
    # Generate all three datasets with realistic volumes
    content_data = generate_content_metadata(200)
    viewing_data = generate_viewing_data(content_data, 2000)
    engagement_data = generate_engagement_data(viewing_data, 1000)
    
    # Current date for partitioning
    today = datetime.now().strftime("%Y-%m-%d")
    
    # Write each dataset to S3 in the appropriate format
    for dataset, name in [
        (content_data, 'content_metadata'), 
        (viewing_data, 'viewing_data'), 
        (engagement_data, 'engagement_data')
    ]:
        # Write as newline-delimited JSON for better compatibility with Glue/Athena
        ndjson_content = '\n'.join([json.dumps(record) for record in dataset])
        
        # Store in appropriate S3 path with date partitioning
        s3_client.put_object(
            Bucket=BUCKET_NAME,
            Key=f'raw/{name}/batch_date={today}/{name}.json',
            Body=ndjson_content
        )
        
        # Also create a CSV version of viewing data for demonstration purposes
        if name == 'viewing_data':
            # Get all columns from all records
            all_keys = set()
            for item in dataset:
                all_keys.update(item.keys())
            
            # Sort columns for consistent output
            ordered_keys = sorted(list(all_keys))
            
            # Build CSV content
            csv_content = ",".join(ordered_keys) + "\n"
            for item in dataset:
                csv_content += ",".join([str(item.get(k, '')) for k in ordered_keys]) + "\n"
            
            # Store CSV in its own location
            s3_client.put_object(
                Bucket=BUCKET_NAME,
                Key=f'raw/{name}_csv/batch_date={today}/{name}.csv',
                Body=csv_content
            )
    
    return "Successfully generated synthetic media data"

if __name__ == "__main__":
    main()