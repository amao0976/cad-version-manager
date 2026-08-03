import React from 'react';
import { View } from '@tarojs/components';
import styles from './index.module.scss';

interface CardProps {
  children: React.ReactNode;
  className?: string;
  onClick?: () => void;
}

export default function Card({ children, className, onClick }: CardProps) {
  return (
    <View
      className={`${styles.card} ${className || ''} ${onClick ? styles.clickable : ''}`}
      onClick={onClick}
    >
      {children}
    </View>
  );
}
