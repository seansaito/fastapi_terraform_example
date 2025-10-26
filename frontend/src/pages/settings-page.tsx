import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { useAuth } from '@/providers/auth-provider'
import { format } from 'date-fns'

export const SettingsPage = () => {
  const { user } = useAuth()

  if (!user) {
    return null
  }

  const createdAt = format(new Date(user.created_at), 'PPpp')

  return (
    <Card>
      <CardHeader>
        <CardTitle>Profile</CardTitle>
        <CardDescription>Manage the metadata tied to your account.</CardDescription>
      </CardHeader>
      <CardContent className="space-y-3 text-sm">
        <div>
          <p className="text-muted-foreground">Full name</p>
          <p className="font-medium">{user.full_name}</p>
        </div>
        <div>
          <p className="text-muted-foreground">Email</p>
          <p className="font-medium">{user.email}</p>
        </div>
        <div>
          <p className="text-muted-foreground">Status</p>
          <p className="font-medium">{user.is_active ? 'Active' : 'Inactive'}</p>
        </div>
        <div>
          <p className="text-muted-foreground">Member since</p>
          <p className="font-medium">{createdAt}</p>
        </div>
      </CardContent>
    </Card>
  )
}
