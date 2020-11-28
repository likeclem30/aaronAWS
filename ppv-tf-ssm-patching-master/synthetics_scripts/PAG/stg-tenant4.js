var assert = require('assert');
var defaultTimeout = 10000;
var BASE_URL = 'https://app-stg.periscope-solutions.com/app/tenant4';
var LOGIN_URL = '/auth/login?returnUrl=/app/tenant4/home';
var HEALTHCHECK_URL = '/admin/monitoring/';

// Browse healthcheck page and look for the dead badge
//$browser.get(BASE_URL + HEALTHCHECK_URL)
//$browser.wait(function() {
//  return $browser.getPageSource().then(function(source) {
//    if(source.indexOf('Language Pack Service') !== -1) {
//        console.log('Language pack service found');
//        var status = source.indexOf('badge-status-dead');
//        assert.ok(status === -1, 'Dead status found');
//        
//        return true;
//    } 
//
//    return false;
//  });
//}, defaultTimeout / 2);

// Login and check for scorecard load
$browser.get(BASE_URL)
    .then(() => $browser.waitForAndFindElement($driver.By.name('email'), defaultTimeout).then(e => e.sendKeys($secure.USERNAME.toString())))
    .then(() => $browser.waitForAndFindElement($driver.By.name('password'), defaultTimeout).then(e => e.sendKeys($secure.PASSWORD.toString())))
    .then(() => $browser.waitForAndFindElement($driver.By.className('auth0-lock-submit'), defaultTimeout).then(e => e.click()))
    //.then(() => $browser.waitForAndFindElement($driver.By.className('scorecard-grid-operations'), defaultTimeout))
    .then(() => $browser.waitForAndFindElement($driver.By.className('active'), defaultTimeout))
    .then(() => $browser.takeScreenshot());
