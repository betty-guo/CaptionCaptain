const express = require("express");
const router = express.Router();

router.use("/caption", require("./caption"));

module.exports = router;