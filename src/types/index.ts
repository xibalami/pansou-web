// 搜索结果链接类型
export interface ResultLink {
  type: string;
  url: string;
  password?: string;
}

// 搜索结果项类型
export interface ResultItem {
  message_id?: string;
  unique_id?: string;
  channel?: string;
  datetime?: string;
  title: string;
  content?: string;
  links: ResultLink[];
  tags?: string[];
}

// 按网盘类型合并的结果项
export interface MergedResultItem {
  url: string;
  password?: string;
  note: string;
  datetime?: string;
  source?: string;  // 数据来源（频道或插件名称）
}

// 按网盘类型合并的结果
export interface MergedResults {
  [key: string]: MergedResultItem[];
}

// API响应类型
export interface SearchResponse {
  total: number;
  results: ResultItem[];
  merged_by_type: MergedResults;
} 