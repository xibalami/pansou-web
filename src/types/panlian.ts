// ============================================================
// 盘链插件类型定义
// ============================================================

export interface PanlianBaseResponse {
  success: boolean
  message: string
  data?: any
}

export interface PanlianStatus {
  hash: string
  logged_in: boolean
  status: 'pending' | 'active' | 'expired'
  username: string
  login_time: string
  expire_time: string
  expires_in_days: number
}

export interface PanlianStatusResponse extends PanlianBaseResponse {
  data: PanlianStatus
}

export interface PanlianLoginResponse extends PanlianBaseResponse {
  data: {
    username: string
    status: string
  }
}

export interface PanlianLogoutResponse extends PanlianBaseResponse {
  data: {
    status: string
  }
}

export interface PanlianSearchResult {
  title: string
  datetime: string
  link_count: number
  first_link: string
  tags?: string[]
}

export interface PanlianSearchResponse extends PanlianBaseResponse {
  data: {
    keyword: string
    results: PanlianSearchResult[]
  }
}
