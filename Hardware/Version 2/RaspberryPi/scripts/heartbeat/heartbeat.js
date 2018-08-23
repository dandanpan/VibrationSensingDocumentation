var firebase = require('firebase');
var macaddress = require('macaddress');
var diskspace = require('diskspace');
var async = require('async');
var log4js = require('log4js');
var fs = require('fs');
var env = require('node-files-env');
var free = require('freem');

var logfile = 'heartbeat';
var bashConfig = '../../node.config';

env(__dirname + "/" + bashConfig);

log4js.loadAppender('file');
log4js.configure({
  appenders: [
    { type: 'console' },
    { type: 'file',
      filename: '../../logs/' + logfile + '.log',
      category: logfile,
      maxLogSize: 20480,
      backups: 10
    }
  ]
});

var logger = log4js.getLogger(logfile);
logger.setLevel("DEBUG");

// pittsburgh nodes use this -- databaseURL: 'https://footstep-wsn-prod.firebaseio.com/'
// cmusv nodes use this -- databaseURL: 'https://footstep-wsn-cmusv.firebaseio.com/'
var firebaseConfig = {
    databaseURL: 'https://footstep-wsn-cmusv.firebaseio.com/'
};

firebase.initializeApp(firebaseConfig);

setInterval(function(){
  async.waterfall([
    function(callback){
      diskspace.check('/', function (err, total, free, status){
        var data = {};
        data['disk_free'] = free / (1024 * 1024);
        data['disk_total'] = total / (1024 * 1024);
        callback(err, data);
      });
    },
    function(arg, callback){
      var data = arg || {};
      free(function(err, list){
        if(err){
          callback(err);
        } else {
            var mem = list[0];
            data['mem'] = mem;
            callback(null, data);
        }
      });
    },
    function(arg, callback){
      var data = arg || {};
      macaddress.one(process.env.IFACE_NAME, function(err, mac){
          data['mac'] = mac;
          callback(err,data);
      });
    },
    function(arg, callback){
      var data = arg || {};
      data['name'] =  process.env.NODE_NAME; //nodeConfig["NODE_NAME"];
      data['ssh_port'] = process.env.SSH_PORT; //nodeConfig["SSH_PORT"];
      var ifaceName = process.env.IFACE_NAME; //nodeConfig["IFACE_NAME"];
      var iface = macaddress.networkInterfaces()[ifaceName];
      data['localip'] = iface["ipv4"];
      callback(null, data);
    }
  ], function(err, data){
    if(err){
      logger.error(err);
      return;
    }
    data['timestamp'] = new Date().toString();
    firebase.database().ref('nodes/' + data["name"]).update(data).then(function(){
      logger.info("Published data: " + JSON.stringify(data));
    }).catch(function(){
      logger.error("Failed to publish to Firebase");
    });
  });
}, 15000);
