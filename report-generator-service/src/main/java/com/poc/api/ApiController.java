package com.poc.api;

import com.poc.models.Weather;
import com.poc.service.WeatherService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping(value = "/v1/weather")
public class ApiController {

	@Autowired
	private WeatherService dummyService;

	@GetMapping("/now/{country}/{city}")
	public Weather getWeatherCityWise(@PathVariable(name = "country") String country,@PathVariable(name = "city") String city) {
		return dummyService.getWeather(country, city);
	}

	@GetMapping("/hello")
	public String test() {
		return "message";
	}

	@GetMapping("/hello1")
	public String test1() {
		return "message1";
	}

	@Autowired
	private WeatherService weatherService;

	@GetMapping("/schedule2")
	public String schedule() throws InterruptedException {
		weatherService.sleep();
		return "schedule 2";
	}

	@GetMapping("/auto")
	public String auto() throws InterruptedException {
		return "auto";
	}

	@GetMapping("/auto1")
	public String auto1() throws InterruptedException {
		return "auto1";
	}
}
