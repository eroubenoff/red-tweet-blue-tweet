"""Write list of users who tweeted to a CSV, user_list.csv.

The CSV has rows as (user id, number of times tweeted).

This script assumes:
 - MongoDB is listening on localhost/27017
 - The database is called "twitter" with collection "tweets_filtered"
"""

import csv

import pymongo

def export_userlist(client, collection_name):
    """Get all users in collection and export as CSV."""

    data = client["twitter"][collection_name].find(no_cursor_timeout = True)
    count = data.count()

    users = {}
    for i, tweet in enumerate(data):
        # Maintain users as hashmap of (user:number of tweets)
        try:
            users[tweet["user"]["id_str"]] += 1
        except Exception as e:
            users[tweet["user"]["id_str"]] = 1

        if i % 50000 == 0:
            print("Processed {0}/{1} tweets; have {2} users".format(i, count, len(users.keys())))

    with open("user_list.csv", "w") as outfile:
        writer = csv.writer(outfile)
        for user_id, num_tweets in users.items():
            try:
                writer.writerow([user_id, num_tweets])
            except:
                continue

    return


if __name__ == "__main__":
    client = pymongo.MongoClient("localhost", 27017)
    export_userlist(client, "tweets_filtered")