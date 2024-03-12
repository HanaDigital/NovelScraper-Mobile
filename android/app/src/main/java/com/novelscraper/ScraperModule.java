package com.novelscraper;
import android.util.Log;

import androidx.annotation.Nullable;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.NativeModule;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.modules.core.DeviceEventManagerModule;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.bridge.Arguments;

import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Map;
import java.util.HashMap;

public class ScraperModule extends ReactContextBaseJavaModule {
	private int listenerCount = 0;

	ScraperModule(ReactApplicationContext context) {
		super(context);
	}

	@ReactMethod
	public void getNovelPaginationPages(String pagePrefixURL, double startPage, double totalPages, Callback callback) {
		try {
			WritableArray novelPaginationPages = Arguments.createArray();
			for (int i = (int)startPage; i <= (int)totalPages; i++) {
				Document doc = Jsoup
					.connect(pagePrefixURL + i)
					.userAgent("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.0.0 Safari/537.36")
					.header("Accept-Language", "*")
					.get();
				novelPaginationPages.pushString(doc.html());
			}
			callback.invoke(null, novelPaginationPages);
		} catch (IOException e) {
			Log.d("ERROR", e.toString());
			callback.invoke(e, null);
		}
	}

	@ReactMethod
	public void getNovelChapterPages(ReadableArray chapterLinks, Callback callback) {
		try {
			WritableArray novelChapterPages = Arguments.createArray();
			for (int i = 0; i < chapterLinks.size(); i++) {
				Log.d("INFO", "Downloading: " + chapterLinks.getString(i));
				Document doc = Jsoup
					.connect(chapterLinks.getString(i))
					.userAgent("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.0.0 Safari/537.36")
					.header("Accept-Language", "*")
					.get();
				novelChapterPages.pushString(doc.html());
			}
			callback.invoke(null, novelChapterPages);
		} catch (IOException e) {
			Log.d("ERROR", e.toString());
			callback.invoke(e, null);
		}
	}

	private void sendEvent(ReactContext reactContext, String eventName, @Nullable WritableMap params) {
		reactContext
			.getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
			.emit(eventName, params);
	}

	@ReactMethod
	public void addListener(String eventName) {
		if (listenerCount == 0) {
			// Set up any upstream listeners or background tasks as necessary
		}

		listenerCount += 1;
	}

	@ReactMethod
	public void removeListeners(Integer count) {
		listenerCount -= count;
		if (listenerCount == 0) {
			// Remove upstream listeners, stop unnecessary background tasks
		}
	}

	@Override
	public String getName() {
		return "ScraperModule";
	}
}
