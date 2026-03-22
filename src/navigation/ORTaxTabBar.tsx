import type { BottomTabBarProps } from '@react-navigation/bottom-tabs';
import { Pressable, StyleSheet, Text, View } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { Ionicons } from '@expo/vector-icons';
import { colors, spacing } from '../theme';
import { FloatingScanButton } from '../components/FloatingScanButton';

const TAB_ICON: Record<
  string,
  { outline: keyof typeof Ionicons.glyphMap; filled: keyof typeof Ionicons.glyphMap }
> = {
  Home: { outline: 'home-outline', filled: 'home' },
  Catalog: { outline: 'library-outline', filled: 'library' },
  Quiz: { outline: 'bulb-outline', filled: 'bulb' },
  Profile: { outline: 'person-outline', filled: 'person' },
};

export function ORTaxTabBar({
  state,
  descriptors,
  navigation,
}: BottomTabBarProps) {
  const insets = useSafeAreaInsets();
  const bottomPad = Math.max(insets.bottom, spacing.sm);

  return (
    <View
      style={[
        styles.outer,
        {
          paddingBottom: bottomPad,
        },
      ]}
    >
      <View style={styles.row}>
        {state.routes.map((route, index) => {
          const { options } = descriptors[route.key];
          const rawLabel = options.tabBarLabel ?? options.title ?? route.name;
          const label =
            typeof rawLabel === 'string' ? rawLabel : String(route.name);
          const isFocused = state.index === index;

          if (route.name === 'Scan') {
            return (
              <View key={route.key} style={styles.scanColumn}>
                <FloatingScanButton
                  focused={isFocused}
                  onPress={() => {
                    const event = navigation.emit({
                      type: 'tabPress',
                      target: route.key,
                      canPreventDefault: true,
                    });
                    if (!isFocused && !event.defaultPrevented) {
                      navigation.navigate(route.name);
                    }
                  }}
                />
              </View>
            );
          }

          const icons = TAB_ICON[route.name];
          const iconName = isFocused && icons ? icons.filled : icons?.outline ?? 'ellipse';
          const color = isFocused ? colors.primary : colors.textSecondary;

          return (
            <Pressable
              key={route.key}
              accessibilityRole="button"
              accessibilityState={{ selected: isFocused }}
              accessibilityLabel={label}
              onPress={() => {
                const event = navigation.emit({
                  type: 'tabPress',
                  target: route.key,
                  canPreventDefault: true,
                });
                if (!isFocused && !event.defaultPrevented) {
                  navigation.navigate(route.name);
                }
              }}
              style={styles.tab}
            >
              <Ionicons name={iconName} size={24} color={color} />
              <Text style={[styles.label, { color }]} numberOfLines={1}>
                {label}
              </Text>
            </Pressable>
          );
        })}
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  outer: {
    backgroundColor: colors.white,
    borderTopWidth: StyleSheet.hairlineWidth,
    borderTopColor: colors.border,
  },
  row: {
    flexDirection: 'row',
    alignItems: 'flex-end',
    justifyContent: 'space-between',
    minHeight: 49,
    paddingHorizontal: spacing.sm,
    paddingTop: spacing.sm,
  },
  tab: {
    flex: 1,
    minHeight: 44,
    alignItems: 'center',
    justifyContent: 'center',
    paddingBottom: 4,
    gap: 2,
  },
  label: {
    fontSize: 10,
    fontWeight: '600',
    letterSpacing: 0.2,
  },
  scanColumn: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'flex-end',
    zIndex: 10,
  },
});
