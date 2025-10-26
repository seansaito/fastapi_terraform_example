import { useMemo } from 'react'
import { z } from 'zod'
import { useForm } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import { Loader2 } from 'lucide-react'
import { Link } from 'react-router-dom'

import { Button } from '@/components/ui/button'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Input } from '@/components/ui/input'
import { Form, FormControl, FormField, FormItem, FormLabel, FormMessage } from '@/components/ui/form'
import { useAuth } from '@/providers/auth-provider'
import { toast } from 'sonner'

const baseSchema = {
  email: z.string().email('Enter a valid email'),
  password: z.string().min(8, 'Minimum 8 characters'),
}

const registerSchema = z.object({
  ...baseSchema,
  full_name: z.string().min(2, 'Your name is required'),
})

const loginSchema = z.object(baseSchema)

type LoginValues = z.infer<typeof loginSchema>
type RegisterValues = z.infer<typeof registerSchema>
type AuthFormValues = LoginValues | RegisterValues
type AuthMode = 'login' | 'register'

type Props = {
  mode: AuthMode
}

export const AuthForm = ({ mode }: Props) => {
  const { login, register } = useAuth()
  const schema = mode === 'login' ? loginSchema : registerSchema
  const form = useForm<AuthFormValues>({
    resolver: zodResolver(schema),
    defaultValues: {
      email: '',
      password: '',
      ...(mode === 'register' ? { full_name: '' } : {}),
    },
  })

  const title = mode === 'login' ? 'Welcome back' : 'Create an account'
  const description = mode === 'login' ? 'Sign in to manage your tasks' : 'Register to start tracking todos'
  const submitLabel = mode === 'login' ? 'Sign in' : 'Create account'
  const alternateLabel = mode === 'login' ? 'Need an account?' : 'Already have an account?'
  const alternateHref = mode === 'login' ? '/register' : '/login'

  const onSubmit = form.handleSubmit(async (values) => {
    try {
      if (mode === 'login') {
        const payload = values as LoginValues
        await login({ email: payload.email, password: payload.password })
      } else {
        const payload = values as RegisterValues
        await register({ email: payload.email, password: payload.password, full_name: payload.full_name })
      }
      toast.success('Authenticated successfully')
    } catch (error) {
      console.error(error)
      toast.error('Authentication failed, please try again')
    }
  })

  const fields = useMemo(() => {
    if (mode === 'login') {
      return [
        { name: 'email' as const, label: 'Email address', type: 'email', autoComplete: 'email' },
        { name: 'password' as const, label: 'Password', type: 'password', autoComplete: 'current-password' },
      ]
    }
    return [
      { name: 'full_name' as const, label: 'Full name', type: 'text', autoComplete: 'name' },
      { name: 'email' as const, label: 'Email address', type: 'email', autoComplete: 'email' },
      { name: 'password' as const, label: 'Password', type: 'password', autoComplete: 'new-password' },
    ]
  }, [mode])

  return (
    <Card className="mx-auto w-full max-w-md">
      <CardHeader>
        <CardTitle>{title}</CardTitle>
        <CardDescription>{description}</CardDescription>
      </CardHeader>
      <CardContent>
        <Form {...form}>
          <form className="space-y-4" onSubmit={onSubmit}>
            {fields.map((field) => (
              <FormField
                key={field.name}
                control={form.control}
                name={field.name}
                render={({ field: controller, fieldState }) => (
                  <FormItem>
                    <FormLabel>{field.label}</FormLabel>
                    <FormControl>
                      <Input type={field.type} autoComplete={field.autoComplete} {...controller} />
                    </FormControl>
                    <FormMessage>{fieldState.error?.message}</FormMessage>
                  </FormItem>
                )}
              />
            ))}
            <Button type="submit" className="w-full" disabled={form.formState.isSubmitting}>
              {form.formState.isSubmitting && <Loader2 className="mr-2 h-4 w-4 animate-spin" />}
              {submitLabel}
            </Button>
            <p className="text-center text-sm text-muted-foreground">
              {alternateLabel}{' '}
              <Link to={alternateHref} className="text-primary hover:underline">
                Go here
              </Link>
            </p>
          </form>
        </Form>
      </CardContent>
    </Card>
  )
}
