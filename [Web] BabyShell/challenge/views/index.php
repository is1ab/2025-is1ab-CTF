<html>
<head>
  <meta name='author' content='makelaris, makelarisjr'>
  <meta name='viewport' content='width=device-width, initial-scale=1, shrink-to-fit=no'>
  <title>BabyShell</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Jaro:opsz@6..72&display=swap" rel="stylesheet">
  <link rel='stylesheet' href='//maxcdn.bootstrapcdn.com/bootstrap/4.0.0/css/bootstrap.min.css' integrity='sha384-Gn5384xqQ1aoWXA+058RXPxPg6fy4IWvTNh0E263XmFcJlSAwiGgFAW/dAiS6JXm' crossorigin='anonymous'>
  <link rel='stylesheet' href='//cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.2/css/all.min.css' integrity='sha512-HK5fgLBL+xu6dm/Ii3z4xhlSUyZgTT9tuc/hSrtw6uzJOvgRr2a9jyxxT1ely+B+xFAmJKVSTbpM/CuL7qxO8w==' crossorigin='anonymous' />
  <link rel='stylesheet' href='/static/css/main.css' />
  <link rel='preconnect' href='//fonts.gstatic.com'>
  <link link='preload' href='//fonts.googleapis.com/css2?family=Press+Start+2P&display=swap' rel='stylesheet'>
  <link rel='icon' href='/assets/favicon.png' />
</head>
<body>
<div id='main' class='container'>
  <h1 id='title'>
  <i class='far fa-smile pulse'></i> <b>BabyShell</b> <i class='far fa-smile pulse'></i>
  </h1>
  <br>
  <div id='img-div'>
    <img id='image' src='/assets/cyberpunk.gif' alt='staring in the abyss'>
    <br>
  </div>
  <h2>You'll grow up:</h2> 
  <br>
  <span id='time'> <?= $time ?></span>
  <div class='form-group'>
    <a href='?format=chw' class='btn-lg btn-danger btn-block text-center'>Don’t Press Me. Nothing Happened!</a>
  </div>
</div>
</body>
<script src='//cdnjs.cloudflare.com/ajax/libs/moment.js/2.29.1/moment.min.js' integrity='sha512-qTXRIMyZIFb8iQcfjXWCO8+M5Tbc38Qi5WzdPOYZHIlZpzBHG3L3by84BBBOiRGiEb7KKtAOAs5qYdUiZiQNNQ==' crossorigin='anonymous'></script> 
<script src='/static/js/main.js'></script>
<script src='/static/js/fr0g.js'></script> <!-- Just a meme -->
</html>