var map;
var orders = [];
var activeOrder = null;
var directions;
var member;
require([
	"esri/urlUtils", "esri/map", "esri/dijit/Directions", 'esri/geometry/Point', 'esri/geometry/Circle',
	"dojo/parser", 'esri/symbols/SimpleMarkerSymbol', 'esri/symbols/SimpleLineSymbol', 'esri/symbols/SimpleFillSymbol', 'esri/Color', 'esri/graphic',
	"dijit/layout/BorderContainer", "dijit/layout/ContentPane", "dojo/domReady!"
], function(
	urlUtils, Map, Directions, Point, Circle,
	parser, SimpleMarkerSymbol, SimpleLineSymbol, SimpleFillSymbol, Color, Graphic
) {
	var CENTER = [-122.3884,37.7586];
	var lastOrderGraphic;
	parser.parse();
	loadMember();

	map = new Map("map", {
		basemap: "streets",
		center: CENTER,
		slider: false,
		minZoom: 17,
		maxZoom: 17,
		zoom: 17
	});

	map.on('load', onMapLoad);

	function loadMember() {
		Manage.Users.get()
			.done(function(data) {
				member = data;
				updateBalance(member.money);
			});
	}

	function onMapLoad() {
		Manage.Orders.getExpiring()
			.done(function(data) {
				orders = data;

				var orderCenterPoints = _.map(orders, function(order) {
					var orderCenterPoint = new Point({
						latitude: order.lat,
						longitude: order.lon
					});
					var graphic = new Graphic(orderCenterPoint, createSymbol("#eee"));
					map.graphics.add(graphic);
					return orderCenterPoint;
				});
				directions.addStops(orderCenterPoints);
				activeOrder = orders[0];
				directions.getDirections();
				init();
			});
		directions = new Directions({
			map: map,
			travelModesServiceUrl: "http://utility.arcgis.com/usrsvcs/servers/cdc3efd03ddd4721b99adce219629489/rest/services/World/Utilities/GPServer",
			canModifyStops: false,
			centerAtSegmentStart: false,
			autoSolve: false
		},"dir");
		directions.startup();
	}

	function createSymbol(color){
		var markerSymbol = new SimpleMarkerSymbol();
		var PATH = "m1077.939941,1959.630005c-38.769897,-190.300049 -107.115967,-348.670044 -189.902954,-495.440063c-61.406982,-108.869995 -132.544006,-209.359985 -198.364014,-314.939941c-21.971985,-35.23999 -40.93396,-72.47998 -62.046997,-109.050049c-42.216003,-73.139954 -76.44397,-157.937927 -74.268982,-267.934937c2.125,-107.473022 33.208008,-193.684021 78.030029,-264.172028c73.718994,-115.934998 197.200989,-210.988983 362.883972,-235.968994c135.468994,-20.423996 262.479004,14.082001 352.539063,66.748016c73.599976,43.037994 130.599976,100.526978 173.919922,168.279999c45.219971,70.715973 76.359985,154.259979 78.969971,263.231964c1.340088,55.830017 -7.799927,107.532043 -20.679932,150.41803c-13.030029,43.408997 -33.98999,79.697998 -52.640015,118.458008c-36.410034,75.660034 -82.050049,144.97998 -127.859985,214.339966c-136.440063,206.609985 -264.5,417.310059 -320.580078,706.030029z";
		markerSymbol.setPath(PATH);
		markerSymbol.setColor(new Color(color));
		markerSymbol.setOutline(new SimpleLineSymbol(
			SimpleLineSymbol.STYLE_SOLID,
			new Color([33,33,33]),
			37*4));
		markerSymbol.setSize("64");
		return markerSymbol;
	}

	function init() {
		$("#cancel").click(function() {
			Manage.Orders.dismiss(activeOrder.id)
				.done(onSuccess);
		});

		$("#confirm").click(function() {
			Manage.Orders.pay(activeOrder.id, member.id)
				.done(function() {
					onSuccess()
					loadMember();
				});
		});

		function onSuccess() {
			map.graphics.remove(map.graphics.graphics[1]);
			map.graphics.remove(lastOrderGraphic);
			orders.shift();
			if (orders.length > 0) {
				activeOrder = orders[0];
				selectOrder(activeOrder);
			} else {
				hideActionSet();
				hideOrderDetails();
				showDataLoader();
				// should go fetch more orders...
				// on the callback of that, hide the default-text
			}
		}

		$("#bonus-pay").hide();
		$.post({
			type: "POST",
			url: "http://api.wunderground.com/api/f276e94d8be86b6b/conditions/q/CA/San_Francisco.json",
			success: function(response) {
				var data = response.current_observation;
				$("#weather").html(data.weather.toLowerCase());
				switch (data.weather) {
					case "Clear":
					case "Partly Cloudy":
					case "Mostly Cloudy":
					case "Foggy":
						$("#pay").html("");
						break;
					default:
						$("#pay").html("You get double the earnings for going out of your way! You rock.");
						break;
				}
			}
		});

		if (_.size(orders) > 0) {
			hideDataLoader();
			selectOrder(activeOrder);
		} else {
			hideActionSet();
			hideOrderDetails();
		}
	}

	function selectOrder(order) {
		var orderCenterPoint = new Point({
			latitude: order.lat,
			longitude: order.lon
		});
		var graphic = new Graphic(orderCenterPoint, createSymbol("#762783"));
		map.graphics.add(graphic);
		lastOrderGraphic = graphic;

		showActionSet();
		showOrderDetails();
		map.centerAt(orderCenterPoint);
		$("#license-plate").html(order.customer.plateNumber);
		$("#car").attr('src', order.customer.vehicleImgUrl);
		timer.setTime(order.expiration - new Date());
	}
});

function hideOrderDetails() {
	$("#order-details").hide();
}

function hideActionSet() {
	$("#action-set").hide();
}

function hideDataLoader() {
	$("#default-data").hide();
}

function showActionSet() {
	$("#action-set").show();
}

function showOrderDetails() {
	$("#order-details").show();
}

function showDataLoader() {
	$("#default-data").show();
}

function updateBalance(value) {
	$("#balance").html((value/100).toFixed(2));
}

var timer = function() {
	var timer = null;

	function setTime(timeToSetTo) {
		timer && window.clearTimeout(timer);
		if (timeToSetTo <= 0) {
			$("#time-left").html(0);
			return;
		}

		$("#time-left").html(Math.round(timeToSetTo/(60*1000)));

		var interval = timeToSetTo/1000 % 60 * 1000 || 60000;
		timer = window.setTimeout(function() {
			var newTime = timeToSetTo - interval;
			setTime(newTime);
		}, interval);
	}

	return {
		setTime: setTime
	};
}();