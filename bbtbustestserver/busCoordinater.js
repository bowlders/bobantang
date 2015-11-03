var _roughBusesData = {
	"fakeBus0": {
progress: 0,
	  direction: true
	},
	"fakeBus1": {
progress: 0,
	  direction: false
	}
}; 

function start() {
	function move_buses () {
		for (p in _roughBusesData) {
			if (_roughBusesData[p].progress >= 109) {
				_roughBusesData[p].progress = 0;
				_roughBusesData[p].direction = !_roughBusesData[p].direction;
				continue;
			}

			_roughBusesData[p].progress += 1;
		}
	}

	setInterval(move_buses, 667);
}

function busesData () {
	function get_decade(aNum) {
		var remainder = aNum % 10;
		if (remainder >= 5) {
			return parseInt(aNum / 10 + 1) * 10 ;
		} else {
			return parseInt(aNum / 10) * 10;
		}
	}
	var busesData = {};
	for (p in _roughBusesData) {
		var current = _roughBusesData[p];

		var stationIndex;
		if (current.direction) {
			stationIndex = 12 - get_decade(current.progress) / 10;
		} else {
			stationIndex = get_decade(current.progress)  / 10 + 1;
		}
		var percent = ((current.progress) - get_decade(current.progress) ) / 10.0;

		var thisBusData = {};
		thisBusData["Name"] = p;
		thisBusData["Direction"] = current.direction;
		thisBusData["Fly"] = false;
		thisBusData["Stop"] = false;
		thisBusData["StationIndex"] = stationIndex;
		thisBusData["Percent"] = percent;
		thisBusData["Latitude"] = "0.0";
		thisBusData["Longitude"] = "0.0";
		thisBusData["Station"] = "fake station name";
		thisBusData["Time"] = 100000;

		busesData[p] = thisBusData;
	}
	return  JSON.stringify(busesData);
}

exports.start = start;
exports.busesData = busesData;


