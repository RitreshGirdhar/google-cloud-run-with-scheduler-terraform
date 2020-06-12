package com.poc.service;

import com.poc.models.Weather;
import org.springframework.stereotype.Service;

@Service
public class WeatherService {

	// dummy service. No 3rd party integration.
	public Weather getWeather(String country, String city) {
		return Weather.builder()
				.name("Cloudy")
				.temperature(17)
				.timestamp(System.currentTimeMillis())
				.build();
	}
}
