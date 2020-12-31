const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp()
//const spawn = require('child-process-promise').spawn;
const path = require('path');
const os = require('os');
const fs = require('fs');


//exports.helloWorld = functions.storage.bucket('csv_files_fdx').object().onFinalize(async (object) => {
exports.helloWorld = functions.storage.bucket('csv_files_fdx').object().onFinalize(async (object) => {
    mainFunction(object);

});

async function mainFunction(object){
    if (!object.name.startsWith('raw/')) {
          return console.log('This is not in the right folder. Quitting');
        }
        else{
            functions.logger.info("This is a raw file, in the right folder");
        }

        var today = getDate();
        var tempPath = await downloadFile(object);
        uploadFile(object, tempPath, today);
        // delete the raw file
    //    return fs.unlinkSync(tempPath);

}

function getDate() {
    var today = new Date();
    var dd = String(today.getDate()).padStart(2, '0');
    var mm = String(today.getMonth() + 1).padStart(2, '0'); //January is 0!
    var yyyy = today.getFullYear();

    today = mm + '_' + dd + '_' + yyyy;
    functions.logger.info("Name will be changed to "+ today);
    return today;
}

async function downloadFile(object){
    const fileBucket = object.bucket;
    const filePath = object.name;
    const fileName = path.basename(filePath);
    // Download file from bucket.
    const bucket = admin.storage().bucket(fileBucket);
    const tempFilePath = path.join(os.tmpdir(), fileName);
    const metadata = {
      contentType: object.contentType,
    };
    await bucket.file(filePath).download({destination: tempFilePath});
    console.log('File downloaded locally to', tempFilePath);

    return tempFilePath;
}

async function uploadFile(object, tempPath, today){
    // Uploading the file.
    console.log("Temp file is "+tempPath);
    const metadata = {
      contentType: object.contentType,
    };

    const bucket = admin.storage().bucket(object.bucket);
    await bucket.upload(tempPath, {
        destination: "excel/"+today+".xlsx",
        metadata: metadata,
    });

    console.log('successfully uploaded');

//    fs.unlinkSync(tempPath);
}
