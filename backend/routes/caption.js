const express = require("express");
const router = express.Router();
const { getCaption } = require("../db/caption");

router.get("/", async (req, res) => {
  const caption = await getCaption();
  res.send(caption);
});

module.exports = router;