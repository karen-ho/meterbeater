package club.meterbeater.server.controllers;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import club.meterbeater.server.entity.Customer;
import club.meterbeater.server.entity.Order;
import club.meterbeater.server.entity.Request;
import club.meterbeater.server.service.MeterBeaterService;

@Controller
public class MainController {

	@Autowired
	private MeterBeaterService mbs;

	@RequestMapping("/partner")
	public String greeting() {
		return "greeting";
	}

	@RequestMapping(value = "/request", method = RequestMethod.POST)
	public @ResponseBody String submitRequest(@RequestBody Request request) {
		Customer customer = mbs.findCustomerById(request.getCustomerId());
		mbs.addOrder(customer, request);
		return "success";
	}

	@RequestMapping(value = "/expiring-orders", method = RequestMethod.GET)
	public @ResponseBody List<Order> getSoonestExpiringOrders() {
		return mbs.findOrdersExpiringInThirtyMins();
	}

	@RequestMapping(value = "/pay", method = RequestMethod.GET)
	public @ResponseBody Customer payOrder(@RequestParam Long orderId, @RequestParam Long payerId) {
		return mbs.completeOrder(orderId, payerId);
	}


	@RequestMapping(value = "/orders", method = RequestMethod.GET)
	public @ResponseBody List<Order> findAllOrders() {
		return mbs.findAllOrders();
	}

	@RequestMapping(value = "/order/{orderId}", method = RequestMethod.DELETE)
	public @ResponseBody String dismissOrder(@PathVariable Long orderId) {
		mbs.dismissOrder(orderId);
		return "success";
	}

	@RequestMapping(value = "/customer/{customerId}", method = RequestMethod.GET)
	public @ResponseBody Customer getCustomer(@PathVariable Long customerId) {
		return mbs.findCustomerById(customerId);
	}

}