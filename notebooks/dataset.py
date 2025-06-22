import pandas as pd

def load_from_csv() -> pd.DataFrame:
    ab_df = pd.read_csv("../data/task_2_ab_dataset.csv")

    ab_df = ab_df.drop("Unnamed: 0", axis=1)
    ab_df["install_time"] = pd.to_datetime(ab_df["install_time"])
    ab_df["payment_time"] = pd.to_datetime(ab_df["payment_time"])

    return ab_df

def remove_payment_duplicates(df: pd.DataFrame) -> pd.DataFrame:
    payments_duplicates_df = df[df[["user_id", "payment_time"]].duplicated(keep=False)]
    print("No. of duplicates:  {}".format(payments_duplicates_df.shape[0]))
    print("No. of payments:    {}".format(payments_duplicates_df["payment_time"].notna().sum()))

    df_ = df.drop_duplicates(subset=["user_id", "payment_time"])

    return df_

def remove_user_group_duplicates(df: pd.DataFrame) -> pd.DataFrame:
    user_group_duplicates_df = df[["user_id", "ab_group"]].drop_duplicates()
    user_group_duplicates_df = user_group_duplicates_df[user_group_duplicates_df["user_id"].duplicated(keep=False)]
    users_dupl_across_groups = user_group_duplicates_df["user_id"].unique()

    print("No. of users duplicated across groups:   {}".format(len(users_dupl_across_groups)))

    df_ = df[~df["user_id"].isin(users_dupl_across_groups)]

    return df_