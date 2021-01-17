const express = require("express");
const router = express.Router();
const { getCaption } = require("../db/caption");

router.post("/", async (req, res) => {
    // parse req
  const imageWords = req.body.words;
  console.log("got request... words:");
  console.log(imageWords);
  const caption = await getCaption(imageWords);
  res.send(caption);
});

module.exports = router;