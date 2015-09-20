package club.meterbeater.server.service;

import java.io.InputStream;
import java.util.ArrayList;
import java.util.Date;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.TreeSet;

import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.NameValuePair;
import org.apache.http.client.HttpClient;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.entity.ContentType;
import org.apache.http.entity.StringEntity;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.message.BasicNameValuePair;
import org.joda.time.DateTime;
import org.springframework.stereotype.Service;

import com.google.common.collect.Lists;
import com.google.common.collect.Maps;
import com.google.common.collect.Sets;

import club.meterbeater.server.entity.Customer;
import club.meterbeater.server.entity.MemberLog;
import club.meterbeater.server.entity.Order;
import club.meterbeater.server.entity.OrderComparator;
import club.meterbeater.server.entity.Request;

@Service
public class MeterBeaterService {

	public static Map<Long,Customer> CUSTOMER_MAP = Maps.newHashMap();
	public static Map<Long,Order> ORDER_MAP = Maps.newHashMap();
	public static TreeSet<Order> ORDER_TREE_SET = Sets.newTreeSet(new OrderComparator());

	static {
		Customer robin = new Customer();
		robin.setId(1L);
		robin.setName("Robin Pearson");
		robin.setPlateNumber("7CBA4029");
		robin.setMoney(1500);
		robin.setVehicleImgUrl("http://www.diseno-art.com/news_content/wp-content/uploads/2013/02/2014-Honda-NSX.jpg");
		robin.setMagnetUsername("jane.doe");

		Customer dan = new Customer();
		dan.setId(2L);
		dan.setName("Dan Chan");
		dan.setPlateNumber("7URL8920");
		dan.setMoney(1200);
		dan.setVehicleImgUrl("http://uncrate.com/p/2013/09/bmw-i8-1-xl.jpg");

		Customer karen = new Customer();
		karen.setId(3L);
		karen.setName("Karen Harding");
		karen.setPlateNumber("5BEL9933");
		karen.setMoney(700);
		karen.setVehicleImgUrl("http://images.dealer.com/ddc/vehicles/2015/Honda/Civic/Coupe/trim_Si_8bd237/color/Crystal%20Black%20Pearl-BK-35,35,35-640-en_US.jpg");

		Customer art = new Customer();
		art.setId(4L);
		art.setName("Art Devoss");
		art.setPlateNumber("7URL8920");
		art.setMoney(900);
		art.setVehicleImgUrl("");

		Customer neil = new Customer();
		neil.setId(5L);
		neil.setName("Neil Chopra");
		neil.setPlateNumber("7URL8920");
		neil.setMoney(2700);
		neil.setVehicleImgUrl("");

		Customer steve = new Customer();
		steve.setId(6L);
		steve.setName("Steve Xi");
		steve.setPlateNumber("7URL8920");
		steve.setMoney(1300);
		steve.setVehicleImgUrl("");

		Customer sameer = new Customer();
		sameer.setId(7L);
		sameer.setName("Sameer Patel");
		sameer.setPlateNumber("7URL8920");
		sameer.setMoney(400);
		sameer.setVehicleImgUrl("");

		Customer katie = new Customer();
		katie.setId(8L);
		katie.setName("Katie Sahr");
		katie.setPlateNumber("7URL8920");
		katie.setMoney(200);
		katie.setVehicleImgUrl("");

		CUSTOMER_MAP.put(robin.getId(), robin);
		CUSTOMER_MAP.put(dan.getId(), dan);
		CUSTOMER_MAP.put(karen.getId(), karen);
		CUSTOMER_MAP.put(art.getId(), art);
		CUSTOMER_MAP.put(neil.getId(), neil);
		CUSTOMER_MAP.put(steve.getId(), steve);
		CUSTOMER_MAP.put(sameer.getId(), sameer);
		CUSTOMER_MAP.put(katie.getId(), katie);
	}

	public Customer findCustomerById(Long customerId) {
		return CUSTOMER_MAP.get(customerId);
	}

	public void addOrder(Customer customer, Request request) {
		Order order = new Order();
		order.setCustomer(customer);
		order.setExpiration(new DateTime().plusMinutes(request.getMinutes()).toDate());
		order.setLat(request.getLat());
		order.setLon(request.getLon());

		ORDER_TREE_SET.add(order);
		ORDER_MAP.put(order.getId(), order);
		customer.getMemberLogs().add(new MemberLog(new Date(), MemberLog.MemberLogType.ORDER));
	}

	public List<Order> findAllOrders() {
		return ORDER_TREE_SET.isEmpty() ? Lists.newArrayList() : new ArrayList<>(ORDER_TREE_SET);
	}

	public List<Order> findOrdersExpiringInThirtyMins() {
		if(ORDER_TREE_SET.isEmpty())
			return Lists.newArrayList();

		Date now = new Date();

		Order dummyOrder = new Order();
		dummyOrder.setExpiration(new DateTime().plusMinutes(30).toDate());

		//Clean up old orders
		ORDER_TREE_SET.first();
		Iterator<Order> orderIterator = ORDER_TREE_SET.iterator();
		Order next = orderIterator.next();
		while(next != null && next.getExpiration().before(now)) {
			orderIterator.remove();
			next = orderIterator.next();
		}

		ORDER_TREE_SET.add(dummyOrder);
		List<Order> ret = new ArrayList<>(ORDER_TREE_SET.subSet(ORDER_TREE_SET.first(), dummyOrder));
		ORDER_TREE_SET.remove(dummyOrder);

		return ret;
	}

	public Customer completeOrder(Long orderId, Long payerId) {
		Order toComplete = ORDER_MAP.get(orderId);
		Request request = new Request();
		request.setCustomerId(toComplete.getCustomer().getId());
		request.setLat(toComplete.getLat());
		request.setLon(toComplete.getLon());
		request.setMinutes(60);

		//give the payer some cash
		Customer payer = CUSTOMER_MAP.get(payerId);
		payer.setMoney(payer.getMoney() + 500);

		//Add a new order for 60 minutes from now
		addOrder(toComplete.getCustomer(), request);

		deleteOrder(orderId);

		toComplete.getCustomer().getMemberLogs().add(new MemberLog(new Date(), MemberLog.MemberLogType.ORDER_COMPLETED));

		sendNotificationToUser(toComplete.getCustomer());

		return payer;
	}

	public void dismissOrder(Long orderId) {
		Order toComplete = deleteOrder(orderId);
		toComplete.getCustomer().getMemberLogs().add(new MemberLog(new Date(), MemberLog.MemberLogType.CANCELLATION));
	}

	private Order deleteOrder(Long orderId) {
		Order toComplete = ORDER_MAP.get(orderId);
		ORDER_TREE_SET.remove(toComplete);
		ORDER_MAP.remove(toComplete);
		return toComplete;
	}

	public void sendNotificationToUser(Customer customer) {
		try {

			HttpClient httpclient = HttpClients.createDefault();

			HttpPost httppost = new HttpPost("https://localhost:3000/mmxmgmt/api/v1/send_message");
			httppost.setHeader("X-mmx-app-id", "mrpiesggwys");
			httppost.setHeader("X-mmx-api-key", "bc1e6b4e-ed2a-498b-b85a-6da80295c037");
			httppost.setHeader("Content-Type", "application/json");
			httppost.setEntity(
					new StringEntity("{" +
							"\"recipientUsernames\":[\"" + customer.getMagnetUsername() + "\"]," +
							"\"content\":\"Your meter has been reloaded for another hour!\"" +
							"}",
					ContentType.create("application/json")));

			//Execute and get the response.
			HttpResponse response = httpclient.execute(httppost);
			HttpEntity entity = response.getEntity();

			if (entity != null) {
				InputStream instream = entity.getContent();
				try {
					// do something useful
				} finally {
					instream.close();
				}
			}
		} catch(Exception e) {
			//Do nothing
		}
	}

}
