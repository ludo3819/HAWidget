import React, { useState, useEffect } from 'react';
import { StyleSheet, View, Text } from 'react-native';
import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import HomeScreen from './screens/HomeScreen';
import SettingsScreen from './screens/SettingsScreen';
import * as SecureStore from 'react-native-secure-storage';

const Stack = createNativeStackNavigator();

export default function App() {
  const [isConfigured, setIsConfigured] = useState(false);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    checkConfiguration();
  }, []);

  const checkConfiguration = async () => {
    try {
      const baseURL = await SecureStore.getItem('baseURL');
      const token = await SecureStore.getItem('accessToken');
      
      if (baseURL && token) {
        setIsConfigured(true);
      }
    } catch (error) {
      console.error('Erreur vérification config:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleConfigured = () => {
    setIsConfigured(true);
  };

  if (loading) {
    return (
      <View style={styles.container}>
        <Text style={styles.title}>HAWidget</Text>
        <Text style={styles.subtitle}>Chargement...</Text>
      </View>
    );
  }

  return (
    <NavigationContainer>
      <Stack.Navigator
        screenOptions={{
          headerShown: true,
          headerStyle: {
            backgroundColor: '#007AFF',
          },
          headerTintColor: '#fff',
          headerTitleStyle: {
            fontWeight: 'bold',
          },
        }}
      >
        {isConfigured ? (
          <Stack.Screen
            name="Home"
            component={HomeScreen}
            options={{
              title: 'Entités HA',
            }}
          />
        ) : (
          <Stack.Screen
            name="Settings"
            options={{
              title: 'Configuration',
              headerLeft: () => null,
            }}
          >
            {(props) => (
              <SettingsScreen {...props} onConfigured={handleConfigured} />
            )}
          </Stack.Screen>
        )}
      </Stack.Navigator>
    </NavigationContainer>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#fff',
    alignItems: 'center',
    justifyContent: 'center',
  },
  title: {
    fontSize: 32,
    fontWeight: 'bold',
    color: '#007AFF',
    marginBottom: 10,
  },
  subtitle: {
    fontSize: 16,
    color: '#666',
  },
});
