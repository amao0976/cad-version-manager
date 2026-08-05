import React, { useState, useEffect, useCallback } from 'react';
import { View, Text, ScrollView } from '@tarojs/components';
import Taro, { useDidShow } from '@tarojs/taro';
import { apiService } from '../../services/api';
import { isUserLoggedIn } from '../../store/auth';
import styles from './index.module.scss';

const WEEKDAYS = ['日', '一', '二', '三', '四', '五', '六'];

function formatDate(d: Date): string {
  const y = d.getFullYear();
  const m = String(d.getMonth() + 1).padStart(2, '0');
  const day = String(d.getDate()).padStart(2, '0');
  return `${y}-${m}-${day}`;
}

function isSameDay(d1: Date, d2: Date): boolean {
  return d1.getFullYear() === d2.getFullYear() &&
         d1.getMonth() === d2.getMonth() &&
         d1.getDate() === d2.getDate();
}

function CalendarPage() {
  const [viewMode, setViewMode] = useState<'month' | 'week'>('month');
  const [currentDate, setCurrentDate] = useState(new Date());
  const [events, setEvents] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [selectedDate, setSelectedDate] = useState<string | null>(null);

  const loadData = useCallback(async () => {
    if (!isUserLoggedIn()) {
      Taro.reLaunch({ url: '/pages/login/index' });
      return;
    }

    try {
      setLoading(true);
      let startDate: Date, endDate: Date;

      if (viewMode === 'month') {
        startDate = new Date(currentDate.getFullYear(), currentDate.getMonth(), 1);
        endDate = new Date(currentDate.getFullYear(), currentDate.getMonth() + 1, 0);
      } else {
        startDate = new Date(currentDate);
        startDate.setDate(currentDate.getDate() - currentDate.getDay());
        endDate = new Date(startDate);
        endDate.setDate(startDate.getDate() + 6);
      }

      const res = await apiService.inspectionRequests.calendar(
        formatDate(startDate),
        formatDate(endDate)
      );
      setEvents(res.data || []);
    } catch (err: any) {
      console.error('[Calendar] 加载失败:', err);
      Taro.showToast({ title: err?.message || '加载失败', icon: 'none' });
    } finally {
      setLoading(false);
    }
  }, [viewMode, currentDate]);

  useEffect(() => {
    loadData();
  }, [loadData]);

  useDidShow(() => {
    loadData();
  });

  const changePeriod = (delta: number) => {
    const d = new Date(currentDate);
    if (viewMode === 'month') {
      d.setMonth(d.getMonth() + delta);
    } else {
      d.setDate(d.getDate() + delta * 7);
    }
    setCurrentDate(d);
    setSelectedDate(null);
  };

  const goToToday = () => {
    setCurrentDate(new Date());
    setSelectedDate(formatDate(new Date()));
  };

  const changeView = (mode: 'month' | 'week') => {
    setViewMode(mode);
  };

  const showEventDetail = (event: any) => {
    Taro.navigateTo({ url: `/pages/request-detail/index?id=${event.id}` });
  };

  const getEventsForDate = (dateStr: string) => {
    return events.filter(e => e.start === dateStr);
  };

  const renderMonthView = () => {
    const year = currentDate.getFullYear();
    const month = currentDate.getMonth();
    const firstDay = new Date(year, month, 1);
    const lastDay = new Date(year, month + 1, 0);
    const startDayOfWeek = firstDay.getDay();
    const totalDays = lastDay.getDate();
    const today = new Date();

    const prevMonthLastDay = new Date(year, month, 0).getDate();
    const totalCells = Math.ceil((startDayOfWeek + totalDays) / 7) * 7;

    const cells: React.ReactNode[] = [];
    for (let i = 0; i < 7; i++) {
      cells.push(
        <View key={`h-${i}`} className={styles.monthHeaderCell}>
          <Text>{WEEKDAYS[i]}</Text>
        </View>
      );
    }

    for (let i = 0; i < totalCells; i++) {
      let dayNum: number, cellDate: Date, otherMonth = false;

      if (i < startDayOfWeek) {
        dayNum = prevMonthLastDay - startDayOfWeek + 1 + i;
        cellDate = new Date(year, month - 1, dayNum);
        otherMonth = true;
      } else if (i >= startDayOfWeek + totalDays) {
        dayNum = i - startDayOfWeek - totalDays + 1;
        cellDate = new Date(year, month + 1, dayNum);
        otherMonth = true;
      } else {
        dayNum = i - startDayOfWeek + 1;
        cellDate = new Date(year, month, dayNum);
      }

      const dateStr = formatDate(cellDate);
      const dayEvents = getEventsForDate(dateStr);
      const isToday = isSameDay(cellDate, today);
      const isSelected = selectedDate === dateStr;

      let cellClass = styles.monthCell;
      if (otherMonth) cellClass += ' ' + styles.monthCellOther;
      if (isToday) cellClass += ' ' + styles.monthCellToday;
      if (isSelected) cellClass += ' ' + styles.monthCellSelected;

      const maxShow = 2;
      const displayEvents = dayEvents.slice(0, maxShow);

      cells.push(
        <View
          key={`c-${dateStr}`}
          className={cellClass}
          onClick={() => setSelectedDate(dateStr)}
        >
          <Text className={styles.cellDate}>{dayNum}</Text>
          {displayEvents.map(ev => (
            <Text
              key={ev.id}
              className={styles.eventDot}
              style={{ backgroundColor: ev.color }}
              onClick={(e) => { e.stopPropagation(); showEventDetail(ev); }}
            >
              {ev.title}
            </Text>
          ))}
          {dayEvents.length > maxShow && (
            <Text className={styles.moreLink}>+{dayEvents.length - maxShow}</Text>
          )}
        </View>
      );
    }

    return (
      <View>
        <View className={styles.monthHeader}>{cells.slice(0, 7)}</View>
        <View className={styles.monthGrid}>{cells.slice(7)}</View>
      </View>
    );
  };

  const renderWeekView = () => {
    const startOfWeek = new Date(currentDate);
    startOfWeek.setDate(currentDate.getDate() - currentDate.getDay());
    const today = new Date();

    const columns: React.ReactNode[] = [];
    for (let i = 0; i < 7; i++) {
      const d = new Date(startOfWeek);
      d.setDate(startOfWeek.getDate() + i);
      const dateStr = formatDate(d);
      const dayEvents = getEventsForDate(dateStr);
      const isToday = isSameDay(d, today);

      let headerClass = styles.weekHeader;
      if (isToday) headerClass += ' ' + styles.weekHeaderToday;

      columns.push(
        <View key={`w-${dateStr}`} className={styles.weekColumn}>
          <View className={headerClass}>
            <Text>{WEEKDAYS[i]}</Text>
            <Text>{d.getMonth() + 1}/{d.getDate()}</Text>
          </View>
          <View className={styles.weekBody}>
            {dayEvents.map(ev => (
              <View
                key={ev.id}
                className={styles.eventDot}
                style={{ backgroundColor: ev.color, marginBottom: '8rpx' }}
                onClick={() => showEventDetail(ev)}
              >
                <Text>{ev.title}</Text>
              </View>
            ))}
          </View>
        </View>
      );
    }

    return (
      <ScrollView scrollX className={styles.weekContainer}>
        {columns}
      </ScrollView>
    );
  };

  const selectedEvents = selectedDate ? getEventsForDate(selectedDate) : [];
  const displayEvents = selectedDate ? selectedEvents : events.slice(0, 10);

  const getPeriodTitle = () => {
    if (viewMode === 'month') {
      return `${currentDate.getFullYear()}年${currentDate.getMonth() + 1}月`;
    } else {
      const start = new Date(currentDate);
      start.setDate(currentDate.getDate() - currentDate.getDay());
      const end = new Date(start);
      end.setDate(start.getDate() + 6);
      return `${start.getMonth() + 1}月${start.getDate()}日 - ${end.getMonth() + 1}月${end.getDate()}日`;
    }
  };

  return (
    <View className={styles.page}>
      <View className={styles.header}>
        <View className={styles.navBtn} onClick={() => changePeriod(-1)}>
          <Text>{'<'}</Text>
        </View>
        <Text className={styles.periodTitle}>{getPeriodTitle()}</Text>
        <View className={styles.navBtn} onClick={() => changePeriod(1)}>
          <Text>{'>'}</Text>
        </View>
        <View className={styles.todayBtn} onClick={goToToday}>
          <Text>今天</Text>
        </View>
      </View>

      <View className={styles.viewToggle}>
        <View
          className={`${styles.toggleBtn} ${viewMode === 'month' ? styles.toggleBtnActive : ''}`}
          onClick={() => changeView('month')}
        >
          <Text>月视图</Text>
        </View>
        <View
          className={`${styles.toggleBtn} ${viewMode === 'week' ? styles.toggleBtnActive : ''}`}
          onClick={() => changeView('week')}
        >
          <Text>周视图</Text>
        </View>
      </View>

      <View className={styles.legend}>
        <View className={styles.legendItem}>
          <View className={styles.legendDot} style={{ backgroundColor: '#2563eb' }}></View>
          <Text>已排期</Text>
        </View>
        <View className={styles.legendItem}>
          <View className={styles.legendDot} style={{ backgroundColor: '#f59e0b' }}></View>
          <Text>待处理</Text>
        </View>
      </View>

      {loading ? (
        <View className={styles.loadingState}><Text>加载中...</Text></View>
      ) : viewMode === 'month' ? (
        renderMonthView()
      ) : (
        renderWeekView()
      )}

      <View className={styles.eventList}>
        <View className={styles.eventListHeader}>
          <Text>{selectedDate ? `${selectedDate} 验货申请` : '近期验货安排'}</Text>
          {displayEvents.length > 0 && (
            <Text style={{ fontSize: '24rpx', color: '#999', marginLeft: 'auto' }}>
              共 {displayEvents.length} 条
            </Text>
          )}
        </View>
        {displayEvents.length === 0 ? (
          <View className={styles.emptyState}>
            <Text>{selectedDate ? '当天暂无验货安排' : '暂无验货安排'}</Text>
          </View>
        ) : (
          displayEvents.map(ev => (
            <View
              key={ev.id}
              className={styles.eventItem}
              onClick={() => showEventDetail(ev)}
            >
              <View className={styles.eventColor} style={{ backgroundColor: ev.color }}></View>
              <View className={styles.eventInfo}>
                <Text className={styles.eventTitle}>{ev.title}</Text>
                <Text className={styles.eventMeta}>
                  {ev.inspection_type} · {ev.status_label}
                  {ev.supplier_name ? ` · ${ev.supplier_name}` : ''}
                </Text>
              </View>
            </View>
          ))
        )}
      </View>
    </View>
  );
}

export default CalendarPage;
