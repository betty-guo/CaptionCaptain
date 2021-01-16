const express = require("express");
const router = express.Router();
const { getCaption } = require("../db/caption");

router.get("/", async (req, res) => {
    // parse req
  const googleVisionFoundWords = req;
  const caption = await getCaption(googleVisionFoundWords);
  res.send(caption);
});

module.exports = router;