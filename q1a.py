import pandas as pd
import random
import time

random.seed(42)

def gen(frac, N):
    # Generate an initial random sequence of stock symbols
    p = list(range(1, N + 1))
    random.shuffle(p)
    outvec = p[:] 
    
    # Keep shrinking p according to the fractal probability distribution (70-30 rule) and adding to outvec
    while len(p) > 1:
        p = p[:int(len(p) * frac)]  # Intercept the first frac*len(p) elements
        outvec = p + outvec  
    
    random.shuffle(outvec)  # The outvec is shuffled to form the final list of stock symbols
    return outvec

symbol_range = 70002
# Generate stock symbols that conform to the fractal distribution
stock_symbols = gen(0.3, symbol_range)
# Initialize the transaction table
trades = []
unique_time = 1 

# Set ranges for quantities and prices
quantity_range = (100, 10000)
price_range = (50, 500)

# Create a dictionary that keeps track of the latest price for each stock
last_prices = {}

# Generating transaction data
for stock_symbol in stock_symbols:
    # Randomly generate quantities
    quantity = random.randint(*quantity_range)
    if stock_symbol not in last_prices:
        # If it is the first occurrence, randomly generate the price
        price = random.randint(*price_range)
    else:
        # making sure the change is within [-5, 5]
        last_price = last_prices[stock_symbol]
        price = min(max(last_price + random.randint(-5, 5), price_range[0]), price_range[1])
    
    # Update the prices in the dictionary
    last_prices[stock_symbol] = price
    
    # Add transaction records to the table
    trades.append((f"s{stock_symbol}", unique_time, quantity, price))
    unique_time += 1

df = pd.DataFrame(trades, columns=["stocksymbol", "time", "quantity", "price"])


# (a) Calculate the weighted average price of each stock over the entire time series
start_timea = time.time()  # record start time
weighted_avg_price = df.groupby("stocksymbol").apply(
    lambda x: (x["price"] * x["quantity"]).sum() / x["quantity"].sum()
).reset_index(name="weighted_avg_price")
end_timea = time.time()  # record end time

print(f"a execution time: {end_timea - start_timea:.6f} s")
# weighted_avg_price.to_csv("weighted_avg_price.csv", index=False)
# print("Weighted Average Price:")
# print(weighted_avg_price)

# (b) Calculate 10 unweighted price moving averages for each stock
start_timeb = time.time()
def moving_average(series, n=10):
    return series.rolling(window=n, min_periods=1).mean()

df["unweighted_moving_avg_price"] = df.groupby("stocksymbol")["price"].transform(
    lambda x: moving_average(x, 10)
)
end_timeb = time.time()

print(f"b execution time: {end_timeb - start_timeb:.6f} s")
# df.to_csv("unweighted_moving_avg_price.csv", index=False)
# print("Unweighted Moving Average Price:")
# print(df[["stocksymbol", "unweighted_moving_avg_price"]].head(20))


# (c) Calculate the weighted moving average of 10 times for each stock
def weighted_moving_average(price_series, quantity_series, n=10):
    wm_avg = []
    for i in range(1, len(price_series) + 1):
        window_prices = price_series[max(0, i-n):i]
        window_quantities = quantity_series[max(0, i-n):i]
        wm_avg.append((window_prices * window_quantities).sum() / window_quantities.sum())
    return pd.Series(wm_avg, index=price_series.index)

start_timec = time.time()

df["weighted_moving_avg_price"] = df.groupby("stocksymbol").apply(
    lambda group: weighted_moving_average(group["price"], group["quantity"], n=10)
).reset_index(level=0, drop=True)

end_timec = time.time()

print(f"c execution time: {end_timec - start_timec:.6f} s")
#df.to_csv("weighted_moving_avg_price.csv", index=False)
# print("Weighted Moving Average Price:")
# print(df[["stocksymbol", "time", "price", "quantity", "weighted_moving_avg_price"]])

# (d) Find the best buy/sell time for each stock
def best_trade(prices):
    min_price = float("inf")
    max_profit = 0
    for price in prices:
        min_price = min(min_price, price)
        profit = price - min_price
        max_profit = max(max_profit, profit)
    return max_profit
start_timed = time.time()
best_trades = df.groupby("stocksymbol").apply(
    lambda x: best_trade(x["price"].values)
).reset_index(name="max_profit")
end_timed = time.time()
print(f"d execution time: {end_timed - start_timed:.6f} s")
# best_trades.to_csv("best_trades.csv", index=False)
# print("Best Buy-Sell Opportunity:")
# print(best_trades)
