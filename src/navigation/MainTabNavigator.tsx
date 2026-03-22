import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { ArScreen } from '../screens/ArScreen';
import { CatalogScreen } from '../screens/CatalogScreen';
import { HomeScreen } from '../screens/HomeScreen';
import { ProfileScreen } from '../screens/ProfileScreen';
import { QuizScreen } from '../screens/QuizScreen';
import { ORTaxTabBar } from './ORTaxTabBar';
import type { MainTabParamList } from './types';

const Tab = createBottomTabNavigator<MainTabParamList>();

export function MainTabNavigator() {
  return (
    <Tab.Navigator
      tabBar={(props) => <ORTaxTabBar {...props} />}
      screenOptions={{
        headerShown: false,
      }}
    >
      <Tab.Screen
        name="Home"
        component={HomeScreen}
        options={{ tabBarLabel: 'Home' }}
      />
      <Tab.Screen
        name="Catalog"
        component={CatalogScreen}
        options={{ tabBarLabel: 'Catalog' }}
      />
      <Tab.Screen
        name="Scan"
        component={ArScreen}
        options={{ tabBarLabel: 'Scan' }}
      />
      <Tab.Screen
        name="Quiz"
        component={QuizScreen}
        options={{ tabBarLabel: 'Quiz' }}
      />
      <Tab.Screen
        name="Profile"
        component={ProfileScreen}
        options={{ tabBarLabel: 'Profile' }}
      />
    </Tab.Navigator>
  );
}
