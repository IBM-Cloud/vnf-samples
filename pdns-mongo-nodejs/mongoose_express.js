
const mongoose = require('mongoose')

const options = {
    autoIndex: false, // Don't build indexes
    reconnectTries: 30, // Retry up to 30 times
    reconnectInterval: 500, // Reconnect every 500ms
    poolSize: 10, // Maintain up to 10 socket connections
    // If not connected, return errors immediately rather than waiting for reconnect
    bufferMaxEntries: 0
  }

const connectWithRetry = () => {
  console.log('MongoDB connection with retry')
  mongoose.connect("mongodb://dbuser:dbpassword@testa.testpdns.com:27017/user_db", options).then(()=>{
    console.log('MongoDB is connected')

  }).catch(err=>{
    console.log('MongoDB connection unsuccessful, retry after 5 seconds.')
    setTimeout(connectWithRetry, 5000)
  })
}

const express = require('express')
const app = express()
const port = 3000

app.get('/', (req, res) => {
  connectWithRetry()
  res.send('Hello, MongoDB is connected!')
})

app.listen(port, () => {
  console.log(`Example app listening at http://localhost:${port}`)
})
