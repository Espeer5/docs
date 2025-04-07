import numpy as np
from sklearn import linear_model
import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score
import matplotlib.pyplot as plt

# Load the CSV file
file_path = 'problem_set_1_data.csv'  # Replace with your file path
df = pd.read_csv(file_path)

# Load the csv file into a df
def load_data():
    return pd.read_csv(file_path)

# Split input and outcome data into training and testing sets
def split_data(input, outcome):
    return train_test_split(input, outcome, test_size=0.2, random_state=42)

# Train a logistic estimator on the training data
def train_model(X_train, y_train):
    logr = linear_model.LogisticRegression()
    logr.fit(X_train, y_train)
    return logr

# Compute the accuracy of the model
def compute_acc(test_x, test_y, model):
    return accuracy_score(test_y, model.predict(test_x))

# Compute the disparity between the two groups
def compute_disparity1(df, model):
    groups = df['group']
    grouped = df.groupby('group')
    group_probs = {}
    for group, group_df in grouped:
        X_group = np.column_stack((group_df["x1"], group_df["x2"]))
        y_group = group_df["outcome"]
        y_group_pred = model.predict(X_group)
        group_probs[group] = np.mean(y_group_pred)

    return group_probs[1] - group_probs[0]

if __name__ == "__main__":

    df1 = load_data()

    X_train1, X_test1, y_train1, y_test1 = split_data(
        np.column_stack((df["x1"], df["x2"])),
        df["outcome"])

    logr1 = train_model(X_train1, y_train1)
    acc   = compute_acc(X_test1, y_test1, logr1)
    disp  = compute_disparity1(df1, logr1)

    print(f"Train accuracy: {acc}") # 0.7385
    print(f"Disparity: {disp}")     # 0.174

    # Create a scatter plot of group with respect to each x1 and x2
    # plt.scatter(df['x1'], df['x2'], c=groups, cmap='viridis')
    # plt.show()

    groups = df['group']

    # Measure correlation of group with respect to each of x1 and x2
    correlation_x1 = np.corrcoef(df['x1'], groups)[0, 1]
    correlation_x2 = np.corrcoef(df['x2'], groups)[0, 1]

    print(f"Correlation of group with x1: {correlation_x1}") # .341
    print(f"Correlation of group with x2: {correlation_x2}") # .009

    # Load a fresh copy of the data
    df = pd.read_csv(file_path)

    # Train a classifier using only x2
    X_train2, X_test2, y_train2, y_test2 = split_data(df[["x2"]], df["outcome"])
    logr2 = train_model(X_train2, y_train2)
    acc2 = compute_acc(X_test2, y_test2, logr2)

    # Chunk the validation set by group
    grouped = df.groupby('group')

    # Measure the probability of a true output for each group
    group_probs = {}
    for group, group_df in grouped:
        X_group = group_df[["x2"]]
        y_group = group_df["outcome"]
        y_group_pred = logr2.predict(X_group)
        group_probs[group] = np.mean(y_group_pred)

    disparity2 = group_probs[1] - group_probs[0] # ~.00649

    print(f"Train accuracy: {acc2}")
    print(f"Disparity: {disparity2}")
