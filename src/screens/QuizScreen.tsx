import { StyleSheet, Text, View } from 'react-native';
import { colors, spacing } from '../theme';

export function QuizScreen() {
  return (
    <View style={styles.container}>
      <Text style={styles.title}>Quiz</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: colors.background,
    padding: spacing.md,
  },
  title: {
    fontSize: 22,
    fontWeight: '700',
    color: colors.text,
  },
});
