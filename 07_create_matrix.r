#===============================================================
# Create the adjacency matrix indicating which of our users
# follow which politicians.
#===============================================================

library(Matrix)
library(methods)  # it doesn't work without this, not sure why

#===============================================================
# CENSUS: M = 443
# Creates list of all IDs in followers_lists (i.e., senators,
# representatives, and governors)
#===============================================================

outfolder <- "followers_lists/" # followers_lists_new
files <- list.files(outfolder, full.names = TRUE)
census <- gsub(".*/(.*).csv", files, repl = "\\1")

m <- length(census)

#===============================================================
# USERS: N = 2,839,448
# Creates list of all IDs of users in tweet collection
#===============================================================

# Cast users to a one-dimensional list
users <- read.csv("user_list.csv", colClasses = c("numeric", "NULL"))
users <- users[0:nrow(users), ]
save(users, file = "users_list.Rdata")

n <- length(users)

#===============================================================
# CREATE MATRIX
# Rows: users from collection (nrow = 2839448)
# Columns: politicians (ncol = 443)
# x[i][j] will be 1 if user i follows politician j
#===============================================================

rows <- list()
columns <- list()

progress <- txtProgressBar(min = 1, max = m, style = 3)

for (j in 1:m) {
    # Load list of followers for this politician; cast to one-dimensional list
    followers <- read.csv(files[j], colClasses = ("numeric"))
    followers <- followers[1:nrow(followers), ]

    # Figure out which of our users follow them
    to_add <- which(users %in% followers)
    rows[[j]] <- to_add
    columns[[j]] <- rep(j, length(to_add))

    setTxtProgressBar(progress, j)
}

rows <- unlist(rows)
columns <- unlist(columns)

# Prepare matrix. Rows are users from our collection; columns are politicians.
x <- sparseMatrix(i = rows, j = columns)
rownames(x) <- users[1:n]
colnames(x) <- census[1:m]

save(x, file="sparse_matrix.Rdata")