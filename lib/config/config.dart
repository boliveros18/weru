const String appHeadquarterMaxDistanceMeters = '150';
const String appHeadquarterLongitude = '-73.265033';
const String appHeadquarterLatitude = '9.884686';
const String appGpsTrackingTime = '10000';
const String appGpsTrackingMinDistance = '10';
const String appMasterFilesFolder = 'MasterData';
const String appImageFilesFolder = 'Images';
const String appImageBakFilesFolder = 'Images_bak';
const String appMaintenancePassword = '509569';
const String appRibHostName = 'nansoft.co';

const String servidorFTPS = 'nansoft.co';
const int puertoFTPS = 21;
const String userNameFTPS = 'Soporte';
const String passwordFTPS = 'S0porte*123.';
const String pathFTPS = '/WerU_Prueba/MasterData';

const String appRibGetMessagesUrlHost = 'nansoft.co:87';
const String appRibGetMessagesUrlPath =
    '/PruebaWeruC/RibWeb.svc/REST/QueHayNuevo/';
const String appRibSetMessageReceivedUrlMethod =
    '/PruebaWeruC/RibWeb.svc/REST/ReportarMensajeRecibido/';
const String appRibSendMessageEntrada =
    '/PruebaWeruC/RibWeb.svc/REST/RecibirMensajeStream/';
const String appRibSendMessageSalida =
    '/PruebaWeruC/RibWeb.svc/REST/RecibirMensajeStreamSalida/';
const String appRibDeleteMessagesNewInstall =
    '/PruebaWeruC/RibWeb.svc/REST/BorrarMensajesTableta/';
const String appRibSendImagesUrlMethod =
    '/PruebaWeruC/RibWeb.svc/REST/RecibirImagen/';

const String appRibSleepTime = '2000';
const String appRibSleepTimeGPS = '1000';
const String appItemTypeInternalId = 'maq';

const String localDatabasePath = "/data/data/com.example.weru/files";
//var/mobile/Containers/Data/Application/<App_ID>/Documents/database <--end point iOs

Future<String> localFilePath(String value) async {
  return "/data/data/com.example.weru/files/MasterData" + value + ".zip";
  // "\(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])/master.zip"   <-- iOs
// var/mobile/Containers/Data/Application/<App_ID>/Documents/master.zip    <--end point iOs
}

const String localDirectoryPath =
    "/data/data/com.example.weru/files/MasterData";
