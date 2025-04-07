using DataFrames
using MLBase
using Lathe

# Load the data into a df
df = readtable("problem_set_1_data.csv", header=true)

# Split the data into a training and validation set
train, test = Lathe.models.train_test_split(df, .75)

fm = @formula(outcome ~ x1 + x2)

logit = glm(fm, train, Binomial(), ProbitLink())
