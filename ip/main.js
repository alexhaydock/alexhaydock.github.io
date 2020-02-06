// Identify which bit of the document we're going to replace with our generated address
const displayIP = document.querySelector('h1');

// Pick which of the TEST-NET-* ranges we're going to use
// Rouding up to the ceiling number here because if we round down we can produce a zero sometimes and we don't want that.
testNET = Math.ceil(Math.random() * 3);

if (testNET == 1) {
    // 192.0.2.0/24 (TEST-NET-1)
    firstOctets = "192.0.2."
    finalOctet = Math.round(Math.random() * 254);
    generatedIP = firstOctets.concat(finalOctet)
} else if ( testNET == 2 ) {
    // 198.51.100.0/24 (TEST-NET-2)
    firstOctets = "198.51.100."
    finalOctet = Math.round(Math.random() * 254);
    generatedIP = firstOctets.concat(finalOctet)
} else if ( testNET == 3 ) {
    // 203.0.113.0/24 (TEST-NET-3)
    firstOctets = "203.0.113."
    finalOctet = Math.round(Math.random() * 254);
    generatedIP = firstOctets.concat(finalOctet)
} else {
    displayIP.textContent = "Something broke. Please try refreshing.";
    fail;
}

displayIP.textContent = generatedIP;

// generate WHOIS link
whoisPre = "Verify this IP address belongs to nobody <a href='https://who.is/whois-ip/ip-address/";
whoisPost = "' target='_blank'>here</a>.";
var whoisLink = whoisPre + generatedIP + whoisPost;

// Replace the div for our WHOIS link
document.getElementById('whois').innerHTML = '';
var p = document.createElement('p');
p.innerHTML = whoisLink;
document.getElementById('whois').appendChild(p);