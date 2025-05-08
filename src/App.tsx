import React from 'react';
import { Activity, GitBranch, CheckCircle2, AlertCircle, Server, Box, Clock } from 'lucide-react';

function App() {
  const pipelineStatus = {
    ci: { status: 'success', time: '2m ago' },
    staging: { status: 'active', time: 'Running' },
    production: { status: 'idle', time: 'Ready' }
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-900 via-slate-800 to-slate-900 text-white p-6">
      <div className="max-w-6xl mx-auto">
        <header className="flex items-center justify-between mb-12">
          <div className="flex items-center gap-3">
            <div className="p-2 bg-emerald-500/10 rounded-lg">
              <Activity className="w-8 h-8 text-emerald-400" />
            </div>
            <h1 className="text-3xl font-bold bg-gradient-to-r from-white to-slate-300 bg-clip-text text-transparent">
              Pipeline Dashboard
            </h1>
          </div>
          <div className="flex items-center gap-2 text-slate-400">
            <Clock className="w-4 h-4" />
            <span>Last updated: just now</span>
          </div>
        </header>

        <div className="grid gap-6 md:grid-cols-3">
          {/* CI Pipeline Status */}
          <div className="bg-slate-800/50 backdrop-blur-sm rounded-xl p-6 border border-slate-700/50 shadow-lg">
            <div className="flex items-center gap-3 mb-6">
              <div className="p-2 bg-blue-500/10 rounded-lg">
                <GitBranch className="w-5 h-5 text-blue-400" />
              </div>
              <h2 className="text-xl font-semibold">CI Pipeline</h2>
            </div>
            <div className="flex items-center gap-2 text-slate-300">
              <CheckCircle2 className="w-5 h-5 text-emerald-400" />
              <span className="font-medium">Last run:</span>
              <span className="text-slate-400">{pipelineStatus.ci.time}</span>
            </div>
          </div>

          {/* Staging Environment */}
          <div className="bg-slate-800/50 backdrop-blur-sm rounded-xl p-6 border border-slate-700/50 shadow-lg">
            <div className="flex items-center gap-3 mb-6">
              <div className="p-2 bg-purple-500/10 rounded-lg">
                <Server className="w-5 h-5 text-purple-400" />
              </div>
              <h2 className="text-xl font-semibold">Staging</h2>
            </div>
            <div className="flex items-center gap-2 text-slate-300">
              <Activity className="w-5 h-5 text-yellow-400 animate-pulse" />
              <span className="font-medium">Status:</span>
              <span className="text-slate-400">{pipelineStatus.staging.time}</span>
            </div>
          </div>

          {/* Production Environment */}
          <div className="bg-slate-800/50 backdrop-blur-sm rounded-xl p-6 border border-slate-700/50 shadow-lg">
            <div className="flex items-center gap-3 mb-6">
              <div className="p-2 bg-red-500/10 rounded-lg">
                <Box className="w-5 h-5 text-red-400" />
              </div>
              <h2 className="text-xl font-semibold">Production</h2>
            </div>
            <div className="flex items-center gap-2 text-slate-300">
              <AlertCircle className="w-5 h-5 text-blue-400" />
              <span className="font-medium">Status:</span>
              <span className="text-slate-400">{pipelineStatus.production.time}</span>
            </div>
          </div>
        </div>

        <div className="mt-12 bg-slate-800/50 backdrop-blur-sm rounded-xl p-6 border border-slate-700/50 shadow-lg">
          <h2 className="text-xl font-semibold mb-6">Recent Deployments</h2>
          <div className="space-y-4">
            {[
              { env: 'Production', status: 'success', commit: 'feat: add health checks', time: '1 hour ago' },
              { env: 'Staging', status: 'success', commit: 'fix: update dependencies', time: '30 mins ago' },
              { env: 'Staging', status: 'active', commit: 'feat: new dashboard', time: '2 mins ago' }
            ].map((deployment, index) => (
              <div 
                key={index} 
                className="flex items-center justify-between py-3 border-b border-slate-700/50 last:border-0"
              >
                <div className="flex items-center gap-4">
                  <div className="relative">
                    <span className={`block w-3 h-3 rounded-full ${
                      deployment.status === 'success' ? 'bg-emerald-400' : 
                      deployment.status === 'active' ? 'bg-yellow-400 animate-pulse' : 'bg-red-400'
                    }`} />
                    {deployment.status === 'active' && (
                      <span className="absolute inset-0 w-3 h-3 rounded-full bg-yellow-400 animate-ping" />
                    )}
                  </div>
                  <span className="font-medium min-w-[100px]">{deployment.env}</span>
                  <span className="text-slate-400 font-mono text-sm">{deployment.commit}</span>
                </div>
                <span className="text-slate-400 text-sm">{deployment.time}</span>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}

export default App;