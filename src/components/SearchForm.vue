<script setup lang="ts">
import { ref } from 'vue';
import type { SearchParams } from '@/api';
import type { HealthStatus } from '@/api';
import { Button, Input, Icons } from '@/components/ui';

const keyword = ref('');
const loading = ref(false);

// 接收后端健康状态作为 props
const props = defineProps<{
  backendHealth: HealthStatus | null;
}>();

const emit = defineEmits<{
  (e: 'search', params: SearchParams): void;
  (e: 'searchComplete'): void;
}>();

// 从配置中加载用户设置和后端默认配置
const loadUserConfig = () => {
  try {
    const savedChannels = localStorage.getItem('pansou_channels');
    const savedPlugins = localStorage.getItem('pansou_plugins');
    const savedDiskTypes = localStorage.getItem('pansou_disk_types');
    
    // 如果用户已手动设置，使用用户设置
    if (savedChannels !== null || savedPlugins !== null) {
      return {
        channels: savedChannels ? JSON.parse(savedChannels) : [],
        plugins: savedPlugins ? JSON.parse(savedPlugins) : [],
        cloudTypes: savedDiskTypes ? JSON.parse(savedDiskTypes) : undefined
      };
    }
    
    // 如果用户未设置，使用传入的后端配置
    if (props.backendHealth) {
      return {
        channels: props.backendHealth.channels || [],
        plugins: props.backendHealth.plugins || [],
        cloudTypes: savedDiskTypes ? JSON.parse(savedDiskTypes) : undefined
      };
    }
    
    return {
      channels: [],
      plugins: [],
      cloudTypes: undefined
    };
  } catch (err) {
    console.error('加载配置失败:', err);
    return {
      channels: [],
      plugins: [],
      cloudTypes: undefined
    };
  }
};

const handleSearch = () => {
  if (!keyword.value.trim()) {
    return;
  }
  
  loading.value = true;
  
  // 加载配置（用户设置或后端默认缓存）
  const userConfig = loadUserConfig();
  
  // 判断有哪些数据源
  const hasChannels = userConfig.channels && userConfig.channels.length > 0;
  const hasPlugins = userConfig.plugins && userConfig.plugins.length > 0;
  
  // 根据搜索逻辑决定第一次搜索的src参数：
  // 1. 如果同时启用了tg和plugin，第一次只搜索tg
  // 2. 如果只启用了tg，搜索tg
  // 3. 如果只启用了plugin，搜索plugin
  // 4. 如果都没有，使用all（兜底）
  let src: 'all' | 'tg' | 'plugin' = 'all';
  if (hasChannels && hasPlugins) {
    src = 'tg';  // 同时启用，第一次只搜索tg（快速）
  } else if (hasChannels && !hasPlugins) {
    src = 'tg';  // 只启用tg
  } else if (!hasChannels && hasPlugins) {
    src = 'plugin';  // 只启用plugin
  }
  
  const params: SearchParams = {
    kw: keyword.value,
    res: 'merge',
    src: src
  };
  
  // 添加用户配置的参数
  if (hasChannels) {
    // 将频道数组转为逗号分隔的字符串
    (params as any).channels = userConfig.channels.join(',');
  }
  
  if (hasPlugins) {
    params.plugins = userConfig.plugins.join(',');
  }
  
  if (userConfig.cloudTypes && userConfig.cloudTypes.length > 0) {
    // 将网盘类型数组转为逗号分隔的字符串
    (params as any).cloud_types = userConfig.cloudTypes.join(',');
  }
  
  emit('search', params);
  
  // 2秒后重置loading状态
  setTimeout(() => {
    loading.value = false;
    // 不再触发searchComplete事件
  }, 2000);
};
</script>

<template>
  <div class="w-full max-w-content mx-auto">
    <div class="relative w-full">
      <div class="relative flex flex-row items-center w-full">
        <div class="relative w-full">
          <input
            v-model="keyword"
            type="text"
            placeholder="搜索资源、电影、音乐、软件..."
            :disabled="loading"
            @keydown.enter="handleSearch"
            class="flex h-10 outline-none focus:outline-none rounded-md border bg-background px-3 py-2 text-sm file:border-0 file:bg-transparent file:text-sm file:font-medium placeholder:text-muted-foreground focus-visible:outline-none disabled:cursor-not-allowed disabled:opacity-50 w-full text-center pr-12 transition-all duration-300 border-primary/20 hover:border-primary/40 shadow-sm hover:shadow-md focus-visible:shadow-lg focus-visible:ring-primary/30 focus-visible:ring-offset-0 focus-visible:border-primary/60"
          />
          <button
            type="button"
            @click="handleSearch"
            :disabled="loading || !keyword.trim()"
            class="inline-flex items-center justify-center whitespace-nowrap rounded-md text-sm font-medium focus-visible:outline-none disabled:pointer-events-none disabled:opacity-50 w-10 absolute right-0 top-0 h-full rounded-l-none transition-all duration-300 border-0 hover:border hover:border-l-0 hover:border-primary/40 hover:bg-primary hover:text-primary-foreground hover:scale-[1.03]"
          >
            <component 
              :is="loading ? Icons.Loading() : Icons.Send()" 
              :class="[
                'w-4 h-4',
                loading && 'animate-spin'
              ]"
            />
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.search-form {
  display: flex;
  flex-direction: column;
  gap: 1rem;
  width: 100%;
  margin-bottom: 2rem;
}

.search-input-wrapper {
  position: relative;
  width: 100%;
  flex: 1;
}

.search-input {
  width: 100%;
  padding: 0.75rem 1rem;
  border-radius: 0.75rem;
  border: 1px solid #e5e7eb;
  background-color: #fff;
  color: #111827;
  font-size: 1rem;
  outline: none;
  transition: all 0.2s ease;
}

.search-input::placeholder {
  color: #9ca3af;
}

.search-input:focus {
  border-color: #3b82f6;
  box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.2);
}

.search-button {
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 0.75rem 1.5rem;
  border-radius: 0.75rem;
  background-color: #3b82f6;
  color: #fff;
  font-weight: 500;
  font-size: 1rem;
  border: none;
  cursor: pointer;
  transition: all 0.2s ease;
}

.search-button:hover:not(:disabled) {
  background-color: #2563eb;
}

.search-button:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.loading-spinner {
  display: inline-block;
  width: 1rem;
  height: 1rem;
  border: 2px solid rgba(255, 255, 255, 0.3);
  border-radius: 50%;
  border-top-color: #fff;
  animation: spin 0.8s linear infinite;
}

@keyframes spin {
  to {
    transform: rotate(360deg);
  }
}

@media (min-width: 768px) {
  .search-form {
    flex-direction: row;
    align-items: center;
  }
  
  .search-button {
    width: auto;
    white-space: nowrap;
  }
}
</style> 