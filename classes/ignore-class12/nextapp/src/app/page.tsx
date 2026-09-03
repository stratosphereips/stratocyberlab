export default function Home() {
  return (
    <div className="flex min-h-screen items-center justify-center bg-white dark:bg-black">
      <main className="flex flex-col items-center gap-4 text-center">
        <h1 className="text-4xl font-bold text-black dark:text-white">
          Hello World
        </h1>
        <p className="text-lg text-zinc-600 dark:text-zinc-400">
          Project based on Next.js 16.0.6 and React 19.2.0 with all default settings.
        </p>
        <p className="text-base text-zinc-500 dark:text-zinc-500">
          Happy Hacking
        </p>
      </main>
    </div>
  );
}
