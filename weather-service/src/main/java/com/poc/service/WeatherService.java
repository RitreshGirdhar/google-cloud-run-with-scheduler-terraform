package com.poc.service;

import com.poc.models.Weather;
import org.springframework.scheduling.annotation.Async;
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


	@Async
	public void sleep() throws InterruptedException {
		System.out.println("Execute method asynchronously. "
				+ Thread.currentThread().getName());
		System.out.println("schedule 2 sleep");
		int i=0;
		while (i<=360){
			Thread.sleep(1000);
			System.out.println("<<<<<< schedule 2 "+i+"   >>>>>");
			i++;
		}
		System.out.println("post sleep:: schedule 2 ");
	}
}
