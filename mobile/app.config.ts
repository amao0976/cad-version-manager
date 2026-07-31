import { ExpoConfig, ConfigContext } from 'expo/config';

export default ({ config }: ConfigContext): ExpoConfig => ({
  ...config,
  name: '验货管理',
  slug: 'inspection-mobile',
  version: '1.0.0',
  orientation: 'portrait',
  scheme: 'inspection',
  userInterfaceStyle: 'automatic',
  newArchEnabled: true,
  ios: {
    supportsTablet: true,
    bundleIdentifier: 'com.cadversionmanager.inspection',
  },
  android: {
    adaptiveIcon: {
      foregroundImage: './assets/adaptive-icon.png',
      backgroundColor: '#2563EB',
    },
    package: 'com.cadversionmanager.inspection',
  },
  web: {
    favicon: './assets/favicon.png',
  },
  plugins: [
    [
      'expo-camera',
      {
        cameraPermission: '允许验货应用访问相机以拍摄验货照片',
      },
    ],
    [
      'expo-image-picker',
      {
        photosPermission: '允许验货应用访问相册以选择验货照片',
      },
    ],
    [
      'expo-secure-store',
      {
        faceIDPermission: '允许验货应用使用 Face ID 登录',
      },
    ],
  ],
  extra: {
    API_URL: 'http://localhost:3000',
  },
});
