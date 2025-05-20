import csv

# Path to your CSV file
csv_file_path = './games_details.csv'

# IDs to search for
target_team_id = '1610612739'
target_player_id = '2544'

# Counter
count = 0

# Read and count
with open(csv_file_path, newline='') as csvfile:
    reader = csv.DictReader(csvfile)
    for row in reader:
        if row.get('TEAM_ID') == target_team_id and row.get('PLAYER_ID') == target_player_id:
            count += 1

print(f"Occurrences of team_id {target_team_id} and player_id {target_player_id}: {count}")
