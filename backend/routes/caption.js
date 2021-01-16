const express = require("express");
const router = express.Router();
const { getCaption } = require("../db/caption");

router.post("/", async (req, res) => {
    // parse req
  const googleVisionFoundWords = req.body.words;
  console.log(req);
  // map words input to actual keywords (use synonyms)
  const caption = await getCaption(googleVisionFoundWords);
  res.send(caption);
});

module.exports = router;