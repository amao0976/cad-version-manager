import React from 'react';
import { View, Text } from '@tarojs/components';
import styles from './index.module.scss';

interface StatusBadgeProps {
  text: string;
  color?: string;
  bgColor?: string;
}

export default function StatusBadge({ text, color, bgColor }: StatusBadgeProps) {
  const style: React.CSSProperties = {};
  if (color) style.color = color;
  if (bgColor) style.backgroundColor = bgColor;

  return (
    <View className={styles.badge} style={style}>
      <Text>{text}</Text>
    </View>
  );
}
