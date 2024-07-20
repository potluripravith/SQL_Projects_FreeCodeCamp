#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi


# Clear existing data
echo -e "Clearing existing data..."
echo "$($PSQL "TRUNCATE TABLE games, teams RESTART IDENTITY")"

# Read the CSV file and insert unique teams
echo -e "Inserting teams..."
while IFS="," read -r year round winner opponent winner_goals opponent_goals
do
  if [[ $year != "year" ]]
  then
    for team in "$winner" "$opponent"
    do
      # Insert unique teams
      EXISTING_TEAM=$($PSQL "SELECT name FROM teams WHERE name='$team'")
      if [[ -z $EXISTING_TEAM ]]
      then
        echo -e "Inserting team: $team"
        echo "$($PSQL "INSERT INTO teams (name) VALUES ('$team')")"
      fi
    done
  fi
done < games.csv

# Insert games data
echo -e "Inserting games..."
while IFS="," read -r year round winner opponent winner_goals opponent_goals
do
  if [[ $year != "year" ]]
  then
    # Retrieve team IDs
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$winner'")
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$opponent'")
    
    # Insert game data
    echo "$($PSQL "INSERT INTO games (year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES ($year, '$round', $WINNER_ID, $OPPONENT_ID, $winner_goals, $opponent_goals)")"
  fi
done < games.csv


