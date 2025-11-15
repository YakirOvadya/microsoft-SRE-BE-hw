const express = require("express");
const axios = require("axios");

const app = express();

const API_URL = process.env.COINSTAT_URL;
const API_KEY = process.env.COINSTAT_KEY;

let prices = [];

app.get("/", (req, res) => {
  res.json({
    status: "running",
    lastBTCsamples: prices,
  });
});

async function fetchBitcoinValue() {
  try {
    const response = await axios.get(API_URL, {
      headers: {
        accept: "application/json",
        "X-API-KEY": API_KEY,
      },
    });

    // console.log(response);
    const price = response.data.result[0].price;
    // console.log(price);
    prices.push(price);

    if (prices.length > 10) prices.shift();

    console.log(
      `[${new Date().toISOString()}] - BTC value: ${price.toFixed(2)}$`
    );
  } catch (error) {
    console.error("Error fetching BTC value:", error.message);
  }
}

function printAverage() {
  if (prices.length > 0) {
    let sum = 0;
    for (const i of prices) {
      sum = sum + i;
    }
    const avg = sum / prices.length;
    console.log(`BTC average value of the last 10 mins: ${avg.toFixed(2)}$`);
  }
}

// first time
fetchBitcoinValue();
// timers
setInterval(fetchBitcoinValue, 60 * 1000);
setInterval(printAverage, 10 * 60 * 1000);

const PORT = process.env.PORT || 3001;
app.listen(PORT, () => {
  console.log(`Service A running & listening on port ${PORT}`);
});
