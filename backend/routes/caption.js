const express = require("express");
const router = express.Router();
const { getCaption } = require("../db/caption");

router.post("/", async (req, res) => {
    // parse req
  const googleVisionFoundWords = req.body.words;
  console.log(req);
  const caption = await getCaption(googleVisionFoundWords);
  res.send(caption);
});

module.exports = router;