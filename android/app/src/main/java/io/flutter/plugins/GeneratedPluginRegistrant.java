package io.flutter.plugins;

import androidx.annotation.Keep;
import androidx.annotation.NonNull;

import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.plugins.shim.ShimPluginRegistry;

/**
 * Generated file. Do not edit.
 * This file is generated by the Flutter tool based on the
 * plugins that support the Android platform.
 */
@Keep
public final class GeneratedPluginRegistrant {
  public static void registerWith(@NonNull FlutterEngine flutterEngine) {
    ShimPluginRegistry shimPluginRegistry = new ShimPluginRegistry(flutterEngine);
      com.infitio.adharasocketio.AdharaSocketIoPlugin.registerWith(shimPluginRegistry.registrarFor("com.infitio.adharasocketio.AdharaSocketIoPlugin"));
      dev.gilder.tom.apple_sign_in.AppleSignInPlugin.registerWith(shimPluginRegistry.registrarFor("dev.gilder.tom.apple_sign_in.AppleSignInPlugin"));
    flutterEngine.getPlugins().add(new io.flutter.plugins.connectivity.ConnectivityPlugin());
    flutterEngine.getPlugins().add(new io.flutter.plugins.firebasemessaging.FirebaseMessagingPlugin());
      com.kasem.flutter_absolute_path.FlutterAbsolutePathPlugin.registerWith(shimPluginRegistry.registrarFor("com.kasem.flutter_absolute_path.FlutterAbsolutePathPlugin"));
    flutterEngine.getPlugins().add(new chat.com.flutter_chat_bubble.FlutterChatBubblePlugin());
    flutterEngine.getPlugins().add(new com.linecorp.flutter_line_sdk.FlutterLineSdkPlugin());
    flutterEngine.getPlugins().add(new io.flutter.plugins.flutter_plugin_android_lifecycle.FlutterAndroidLifecyclePlugin());
    flutterEngine.getPlugins().add(new com.baseflow.geolocator.GeolocatorPlugin());
    flutterEngine.getPlugins().add(new com.baseflow.googleapiavailability.GoogleApiAvailabilityPlugin());
    flutterEngine.getPlugins().add(new io.flutter.plugins.imagepicker.ImagePickerPlugin());
    flutterEngine.getPlugins().add(new com.baseflow.location_permissions.LocationPermissionsPlugin());
    flutterEngine.getPlugins().add(new com.vitanov.multiimagepicker.MultiImagePickerPlugin());
    flutterEngine.getPlugins().add(new io.flutter.plugins.pathprovider.PathProviderPlugin());
    flutterEngine.getPlugins().add(new io.flutter.plugins.share.SharePlugin());
    flutterEngine.getPlugins().add(new io.flutter.plugins.sharedpreferences.SharedPreferencesPlugin());
    flutterEngine.getPlugins().add(new com.tekartik.sqflite.SqflitePlugin());
    flutterEngine.getPlugins().add(new io.flutter.plugins.urllauncher.UrlLauncherPlugin());
  }
}
