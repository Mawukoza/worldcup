#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
# Truncate the games and teams tables
$PSQL "TRUNCATE TABLE games, teams" 

# This ignores the header of the CSV file starting it from the second line
tail -n +2 games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS; 
do
  # Insert winner team if not found
  $PSQL "INSERT INTO teams (name) SELECT DISTINCT '$WINNER' WHERE NOT EXISTS (SELECT 1 FROM teams WHERE name = '$WINNER')"

  # Retrieve the winner team ID
  WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$WINNER'")

  # Check the exit status of the previous command
  if [ $? -ne 0 ]; then
    echo "Failed to insert winner team: $WINNER"
    continue
  else
    echo "Inserted winner team: $WINNER"
  fi

  # Insert opponent team if not found
  $PSQL "INSERT INTO teams (name) SELECT DISTINCT '$OPPONENT' FROM teams WHERE NOT EXISTS (SELECT 1 FROM teams WHERE name = '$OPPONENT')"

  # Retrieve the opponent team ID
  OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$OPPONENT'")

  # Check the exit status of the previous command
  if [ $? -ne 0 ]; then
    echo "Failed to insert opponent team: $OPPONENT"
    continue
  else
    echo "Inserted opponent team: $OPPONENT"
  fi

  # Insert the data into the games table
  $PSQL "INSERT INTO games (year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES ($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)"
  
  # Check the exit status of the previous command
  if [ $? -ne 0 ]; then
    echo "Failed to insert game: $YEAR, $ROUND, $WINNER vs $OPPONENT, $WINNER_GOALS-$OPPONENT_GOALS"
  else
    echo "Inserted game: $YEAR, $ROUND, $WINNER vs $OPPONENT, $WINNER_GOALS-$OPPONENT_GOALS"
  fi

done