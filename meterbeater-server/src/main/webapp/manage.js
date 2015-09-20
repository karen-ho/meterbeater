var Manage = (function() {
//	var BASE_URL = "http://meterbeater.herokuapp.com/";
	var BASE_URL = "http://172.20.10.3:8080/";

	function getExpiringOrders() {
		return $.get(BASE_URL + 'expiring-orders');
	}

	function dismissOrder(id) {
		return $.ajax({
			url: BASE_URL + 'order/' + id,
			type: 'DELETE'
		});
	}

	function payOrder(orderId, payerId) {
		return $.ajax({
			url: BASE_URL + 'pay?orderId=' + orderId + '&payerId=' + payerId,
			type: 'GET'
		});
	}

	return {
		Orders: {
			getExpiring: getExpiringOrders,
			dismiss: dismissOrder,
			pay: payOrder
		},
		Users: {
			get: function(id) {
				return $.get(BASE_URL + 'customer/1');
			}
		}
	};
})();