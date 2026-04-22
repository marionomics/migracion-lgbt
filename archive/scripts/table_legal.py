def run():
    import pandas as pd

    df = pd.read_csv('auxiliary/equal_marriage.csv')
    df = df.iloc[:,[1,5]].sort_values(by=['year'])

    print(df)


if __name__ == "__main__":
    run()