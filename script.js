// task 5: read through the JavaScript starter code to determine where each given function is declared and where each given function is called.


// input variables
let image = document.querySelector(".image");
let songName = document.querySelector(".song-name");
let artist = document.querySelector(".artist");
let songLink = document.querySelector(".song-link");

// button variable
let add = document.querySelector(".add");


// task 6: declare variables for your display divs: the image url, song name, artist, and song link. Go back to the HTML to check that you are using the correct class names.
let displayImage = document.querySelector(".display-image");
let displaySong = document.querySelector(".display-song");
let displayArtist = document.querySelector(".display-artist");
let displayLink = document.querySelector(".display-link");


// task 7: create and populate an array to store your image urls. Create three more arrays. One to store your song names, one for the artists, and a last one for the song links.

let actualImages = [
  '<img src="https://images.genius.com/ab2b5a62d4b6ba8a49c68449618e5b34.1000x1000x1.png">', '<img src="https://i.scdn.co/image/ab67616d0000b2739a74860d7918c8e38c5220cf">', '<img src="https://i.scdn.co/image/ab67616d0000b273d8ee47b9025eb1b61fcc2051">', '<img src="https://i.scdn.co/image/ab67616d0000b2736014f378562a405be85d9b0b">', '<img src="https://i.scdn.co/image/ab67616d0000b273791d6daf3d05cde2a646c3cd">', '<img src="https://i.scdn.co/image/ab67616d0000b27349d694203245f241a1bcaa72">', '<img src="https://i.scdn.co/image/ab67616d0000b273a0c2b6170271a4274b525d25">', '<img src="https://i.scdn.co/image/ab67616d0000b273c9f744b0d62da795bc21d04a">', '<img src="https://is3-ssl.mzstatic.com/image/thumb/Music/v4/29/4d/9b/294d9bb2-c1e0-5c3c-d5e2-6434fd16974a/825646569618.jpg/600x600bf-60.jpg">'];
let actualSongs = ['Si Me La Haces', 'Más De La Una', 'Amores Prohibidos', 'A Cámara Lenta', 'Su veneno', 'Tití Me Preguntó','Como Tú y Yo', 'La Bachata', 'Hasta Que Te Conocí'];
let actualArtists = ['Sebastain Yatra, Lenny Tavárez, Mariah Angeliq', 'Piso 21, Maluma', 'Juanes', 'Abraham Mateo', 'Aventura', 'Bad Bunny', 'Chayanne', 'Manuel Turizo', 'Maná'];
let actualLinks =
  ['<a href=https://youtu.be/XZyNART9qXQ target=_blank>Link</a>', '<a href=https://youtu.be/dZauWAlZwl4 target=_blank>Link</a>', '<a href=https://youtu.be/xZ8QZ-le3gY target=_blank>Link</a>', '<a href=https://youtu.be/hGBqBFMLte8 target=_blank>Link</a>', '<a href=https://youtu.be/3F1aqvXGVQM target=_blank>Link</a>', '<a href=https://youtu.be/Cr8K88UcO0s target=_blank>Link</a>', '<a href=https://youtu.be/X6gLepxPnDM target=_blank>Link</a>', '<a href=https://youtu.be/TiM_TFpT_DE target=_blank>Link</a>', '<a href=https://youtu.be/vyC8dy8qST8 target=_blank>Link</a>'];

for (let i = 0; i < actualImages.length; i++) {
  let ptag = document.createElement('p')
  let images = actualImages[i]
  ptag.innerHTML = images
  displayImage.append(ptag);
  console.log(actualImages[i])
}

for (let i = 0; i < actualSongs.length; i++) {
  let ptag = document.createElement('p')
  let songs = actualSongs[i]
  ptag.innerHTML = songs
  displaySong.append(ptag);
  console.log(actualSongs[i])
}

for (let i = 0; i < actualArtists.length; i++) {
  let ptag = document.createElement('p')
  let artist = actualArtists[i]
  ptag.innerHTML = artist
  displayArtist.append(ptag);
  console.log(actualArtists[i])
}

for (let i = 0; i < actualLinks.length; i++) {
  let ptag = document.createElement('p')
  let links = actualLinks[i]
  ptag.innerHTML = links
  displayLink.append(ptag);
  console.log(actualLinks[i])
}




//REFACTOR ARRAYS DAY 
// task 11: comment out the arrays data.
// task 12: create an object for each of your songs.
// task 13: inside each object, add key/value pairs to store the image url, song name, artist, and song link.
// task 14: create an array that stores all of the objects.



//REFACTOR LOOPS DAY 
// task 15: update your `addSongInfo` function so the input values are saved in as values in a new object.
// task 16: update your `.push()` so the input object is added to your array of objects.
// task 17: update your loops based on your new array of objects.





function addSongInfo() {

  // task 9: declare a variable to save the user input of the image url. Declare three more variables that save user input: One for the song names, one for the artists, and a last one for the song links.
  let userInputUrl = image.value;
  let userInputSong = songName.value;
  let userInputArtist = artist.value;
  let userInputLink = songLink.value;

  // task 10: use `.push()` to add each input value to the correct array.
  // actualImages.push(`<img src="${userInputUrl}">`);
  // actualSongs.push(userInputSong);
  // actualArtists.push(userInputArtist);
  // actualLinks.push(`<a href=${userInputLink} target=_blank>Link</a>`);

  let ptag1 = document.createElement('p')
  let ptag2 = document.createElement('p')
  let ptag3 = document.createElement('p')
  let ptag4 = document.createElement('p')

  ptag1.innerHTML = `<img src="${userInputUrl}">`;
  ptag2.innerHTML = userInputSong;
  ptag3.innerHTML = userInputArtist;
  ptag4.innerHTML = `<a href=${userInputLink} target=_blank>Link</a>`;
  

  // displayImage.append(`"<img src="${userInputUrl}">"`);
  // displaySong.append(userInputSong);
  // displayArtist.append(userInputArtist);
  // displayLink.append(`"<a href=${userInputLink} target=_blank>Link</a>"`);

  displayImage.append(ptag1);
  displaySong.append(ptag2);
  displayArtist.append(ptag3);
  displayLink.append(ptag4);


  console.log(actualImages)
  console.log(actualSongs)
  console.log(actualArtists)
  console.log(actualLinks)
}




/******** this function empties the display divs each time the button is clicked so that your playlist does not repeatedly add the data too many times. Where should this function be placed???********/
function emptyDisplay() {
  displayImage.innerHTML = "";
  displaySong.innerHTML = "";
  displayArtist.innerHTML = "";
  displayLink.innerHTML = "";
}




function displaySongInfo() {

  // task 8: loop through your images array and display the images to your songs in the correct div. Create three more loops. One for the song names, one for the artists, and a last one for the song links.



}





// click event to add and display songs
add.onclick = function() {
  addSongInfo();
  displaySongInfo();
};

// function call to display stored songs
displaySongInfo();
