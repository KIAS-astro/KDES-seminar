<html>
<head>
<meta http-equiv="content-type" content="text/html; charset=utf-8">
<link href="style.css" type="text/css" rel="stylesheet">
</head>
<body>
<div id="abstract-toggle-bar">
<button id="abstract-toggle-btn" onclick="toggleAllAbstracts()">Expand All Abstracts</button>
</div>
<script>
function toggleAllAbstracts() {
  var details = document.querySelectorAll('details.abstract');
  var btn = document.getElementById('abstract-toggle-btn');
  var allOpen = Array.from(details).every(function(d) { return d.open; });
  details.forEach(function(d) { d.open = !allOpen; });
  btn.textContent = allOpen ? 'Expand All Abstracts' : 'Collapse All Abstracts';
}
</script>
<?php
        include "2026.html";
        include "2025.html";
        include "2024.html";
        include "2023.html";
        include "2022.html";
        include "2021.html";
        include "2020.html";
        include "2019.html";
        include "2018.html";
	include "2017.html";
	include "2016.html";
	include "2015.html";
	include "2014.html";
	include "2013.html";
?>
</body>
</html>
