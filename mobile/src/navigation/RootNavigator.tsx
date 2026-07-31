import React from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { useAuth } from '../context/AuthContext';
import LoginScreen from '../screens/LoginScreen';
import RequestListScreen from '../screens/inspection/RequestListScreen';
import RequestDetailScreen from '../screens/inspection/RequestDetailScreen';
import RecordListScreen from '../screens/inspection/RecordListScreen';
import RecordDetailScreen from '../screens/inspection/RecordDetailScreen';
import ReportScreen from '../screens/inspection/ReportScreen';
import SuppliersScreen from '../screens/inspection/SuppliersScreen';

type RootStackParamList = {
  Login: undefined;
  Main: undefined;
  RequestDetail: { id: number };
  RecordDetail: { id: number };
  Report: { id: number };
};

type TabParamList = {
  Requests: undefined;
  Records: undefined;
  Suppliers: undefined;
  Profile: undefined;
};

const Stack = createNativeStackNavigator<RootStackParamList>();
const Tab = createBottomTabNavigator<TabParamList>();

function MainTabs() {
  return (
    <Tab.Navigator
      screenOptions={{
        headerStyle: {
          backgroundColor: '#2563EB',
        },
        headerTintColor: '#fff',
        headerTitleStyle: {
          fontWeight: 'bold',
        },
        tabBarActiveTintColor: '#2563EB',
        tabBarInactiveTintColor: 'gray',
      }}
    >
      <Tab.Screen
        name="Requests"
        component={RequestListScreen}
        options={{ title: '验货申请', tabBarLabel: '申请' }}
      />
      <Tab.Screen
        name="Records"
        component={RecordListScreen}
        options={{ title: '验货记录', tabBarLabel: '记录' }}
      />
      <Tab.Screen
        name="Suppliers"
        component={SuppliersScreen}
        options={{ title: '供应商', tabBarLabel: '供应商' }}
      />
    </Tab.Navigator>
  );
}

export default function RootNavigator() {
  const { isAuthenticated, isLoading } = useAuth();

  if (isLoading) {
    // 可以显示一个加载指示器
    return null;
  }

  return (
    <Stack.Navigator
      screenOptions={{
        headerStyle: {
          backgroundColor: '#2563EB',
        },
        headerTintColor: '#fff',
        headerTitleStyle: {
          fontWeight: 'bold',
        },
      }}
    >
      {isAuthenticated ? (
        <>
          <Stack.Screen
            name="Main"
            component={MainTabs}
            options={{ headerShown: false }}
          />
          <Stack.Screen
            name="RequestDetail"
            component={RequestDetailScreen}
            options={{ title: '验货申请详情' }}
          />
          <Stack.Screen
            name="RecordDetail"
            component={RecordDetailScreen}
            options={{ title: '验货记录详情' }}
          />
          <Stack.Screen
            name="Report"
            component={ReportScreen}
            options={{ title: '验货报告' }}
          />
        </>
      ) : (
        <Stack.Screen
          name="Login"
          component={LoginScreen}
          options={{ headerShown: false }}
        />
      )}
    </Stack.Navigator>
  );
}
