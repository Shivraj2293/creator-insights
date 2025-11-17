"use client"
import { useRouter } from "next/navigation";

export default function useAuth() {
  const router = useRouter();

  async function login(email: string, password: string) {
    // call backend /auth/login
    try {
      await fetch(process.env.NEXT_PUBLIC_API_BASE + "/auth/login", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        credentials: "include",
        body: JSON.stringify({ email, password }),
      });
      router.push("/dashboard");
    } catch (e) {
      console.error(e);
      alert("Login failed");
    }
  }

  function logout() {
    document.cookie = "access=; Max-Age=0; path=/;"; // backend must clear
    router.push("/login");
  }

  return { login, logout };
}
